# app/crypto/ecc_manager.py
"""
ECC Manager - Core Elliptic Curve Cryptography Operations
Handles all ECC operations for microgrid security including:
- Key pair generation
- ECDH key exchange
- Message encryption/decryption with AES
- Digital signatures with ECDSA
"""

import os
import json
import base64
import hashlib
from datetime import datetime
from typing import Dict, Optional, Tuple, Any
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.exceptions import InvalidSignature
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ECCmanager:
    """
    Main ECC Manager class for microgrid security operations
    Implements SECP256R1 curve for optimal security and performance
    """

    def __init__(self, curve=ec.SECP256R1()):
        """
        Initialize ECC Manager with specified curve

        Args:
            curve: ECC curve to use (default: SECP256R1)
        """
        self.curve = curve
        self.private_key = None
        self.public_key = None
        self.node_id = None
        logger.info(f"ECC Manager initialized with curve: {curve.name}")

    def generate_key_pair(self, node_id: str = "microgrid_node") -> Tuple[
        ec.EllipticCurvePrivateKey, ec.EllipticCurvePublicKey]:
        """
        Generate ECC key pair for this microgrid node

        Args:
            node_id: Unique identifier for this microgrid node

        Returns:
            Tuple of (private_key, public_key)
        """
        try:
            self.node_id = node_id
            self.private_key = ec.generate_private_key(self.curve)
            self.public_key = self.private_key.public_key()

            logger.info(f"Generated ECC key pair for node: {node_id}")
            return self.private_key, self.public_key

        except Exception as e:
            logger.error(f"Key pair generation failed: {e}")
            raise

    def get_public_key_pem(self) -> str:
        """
        Export public key in PEM format for sharing with other nodes

        Returns:
            Public key as PEM string
        """
        if not self.public_key:
            raise ValueError("No public key available. Generate key pair first.")

        pem = self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )

        return pem.decode('utf-8')

    def load_public_key_from_pem(self, pem_data: str) -> ec.EllipticCurvePublicKey:
        """
        Load public key from PEM format (from other microgrid nodes)

        Args:
            pem_data: Public key in PEM format

        Returns:
            Loaded public key object
        """
        try:
            public_key = serialization.load_pem_public_key(pem_data.encode('utf-8'))
            logger.info("Successfully loaded public key from PEM")
            return public_key

        except Exception as e:
            logger.error(f"Failed to load public key from PEM: {e}")
            raise

    def perform_ecdh(self, peer_public_key: ec.EllipticCurvePublicKey,
                     info: bytes = b'microgrid-secure-channel') -> bytes:
        """
        Perform ECDH key exchange to derive shared secret

        Args:
            peer_public_key: Public key from the other microgrid node
            info: Context information for key derivation

        Returns:
            Derived shared secret (32 bytes)
        """
        if not self.private_key:
            raise ValueError("No private key available. Generate key pair first.")

        try:
            # Perform ECDH exchange
            shared_key = self.private_key.exchange(ec.ECDH(), peer_public_key)

            # Derive 256-bit key using HKDF
            derived_key = HKDF(
                algorithm=hashes.SHA256(),
                length=32,
                salt=None,
                info=info,
            ).derive(shared_key)

            logger.info("ECDH key exchange completed successfully")
            return derived_key

        except Exception as e:
            logger.error(f"ECDH key exchange failed: {e}")
            raise

    def encrypt_message(self, message: str, shared_secret: bytes) -> Dict[str, str]:
        """
        Encrypt message using AES-256-CBC with shared secret from ECDH

        Args:
            message: Plain text message to encrypt
            shared_secret: 32-byte shared secret from ECDH

        Returns:
            Dictionary containing encrypted data and IV
        """
        try:
            if isinstance(message, str):
                message_bytes = message.encode('utf-8')
            else:
                message_bytes = message

            # Generate random IV
            iv = os.urandom(16)

            # Create AES cipher
            cipher = Cipher(algorithms.AES(shared_secret), modes.CBC(iv))
            encryptor = cipher.encryptor()

            # Apply PKCS7 padding
            padding_length = 16 - (len(message_bytes) % 16)
            padded_message = message_bytes + bytes([padding_length] * padding_length)

            # Encrypt
            ciphertext = encryptor.update(padded_message) + encryptor.finalize()

            # Create timestamp for replay attack prevention
            timestamp = datetime.utcnow().isoformat()

            encrypted_data = {
                'ciphertext': base64.b64encode(ciphertext).decode('utf-8'),
                'iv': base64.b64encode(iv).decode('utf-8'),
                'timestamp': timestamp,
                'algorithm': 'AES-256-CBC',
                'sender': self.node_id or 'unknown'
            }

            logger.info("Message encrypted successfully")
            return encrypted_data

        except Exception as e:
            logger.error(f"Message encryption failed: {e}")
            raise

    def decrypt_message(self, encrypted_data: Dict[str, str], shared_secret: bytes) -> str:
        """
        Decrypt message using shared secret

        Args:
            encrypted_data: Dictionary containing encrypted message and metadata
            shared_secret: 32-byte shared secret from ECDH

        Returns:
            Decrypted plain text message
        """
        try:
            ciphertext = base64.b64decode(encrypted_data['ciphertext'])
            iv = base64.b64decode(encrypted_data['iv'])

            # Create AES cipher
            cipher = Cipher(algorithms.AES(shared_secret), modes.CBC(iv))
            decryptor = cipher.decryptor()

            # Decrypt
            padded_message = decryptor.update(ciphertext) + decryptor.finalize()

            # Remove PKCS7 padding
            padding_length = padded_message[-1]
            if padding_length > 16:
                raise ValueError("Invalid padding")

            message = padded_message[:-padding_length]

            logger.info("Message decrypted successfully")
            return message.decode('utf-8')

        except Exception as e:
            logger.error(f"Message decryption failed: {e}")
            raise

    def sign_message(self, message: str, include_timestamp: bool = True) -> Dict[str, str]:
        """
        Create digital signature for message using ECDSA

        Args:
            message: Message to sign
            include_timestamp: Whether to include timestamp in signature

        Returns:
            Dictionary containing signature and metadata
        """
        if not self.private_key:
            raise ValueError("No private key available for signing")

        try:
            # Add timestamp to prevent replay attacks
            if include_timestamp:
                timestamp = datetime.utcnow().isoformat()
                message_to_sign = f"{message}:{timestamp}"
            else:
                timestamp = None
                message_to_sign = message

            # Create signature
            signature = self.private_key.sign(
                message_to_sign.encode('utf-8'),
                ec.ECDSA(hashes.SHA256())
            )

            signature_data = {
                'signature': base64.b64encode(signature).decode('utf-8'),
                'message': message,
                'timestamp': timestamp,
                'signer': self.node_id or 'unknown',
                'algorithm': 'ECDSA-SHA256'
            }

            logger.info("Message signed successfully")
            return signature_data

        except Exception as e:
            logger.error(f"Message signing failed: {e}")
            raise

    def verify_signature(self, signature_data: Dict[str, str], public_key: ec.EllipticCurvePublicKey) -> bool:
        """
        Verify digital signature

        Args:
            signature_data: Dictionary containing signature and metadata
            public_key: Public key of the signer

        Returns:
            True if signature is valid, False otherwise
        """
        try:
            signature = base64.b64decode(signature_data['signature'])
            message = signature_data['message']
            timestamp = signature_data.get('timestamp')

            # Reconstruct message that was signed
            if timestamp:
                message_to_verify = f"{message}:{timestamp}"
            else:
                message_to_verify = message

            # Verify signature
            public_key.verify(
                signature,
                message_to_verify.encode('utf-8'),
                ec.ECDSA(hashes.SHA256())
            )

            logger.info("Signature verification successful")
            return True

        except InvalidSignature:
            logger.warning("Invalid signature detected")
            return False
        except Exception as e:
            logger.error(f"Signature verification failed: {e}")
            return False

    def create_secure_message(self, message: str, shared_secret: bytes, sign: bool = True) -> Dict[str, Any]:
        """
        Create a complete secure message with encryption and optional digital signature

        Args:
            message: Plain text message
            shared_secret: Shared secret from ECDH
            sign: Whether to include digital signature

        Returns:
            Complete secure message package
        """
        try:
            # Encrypt the message
            encrypted_data = self.encrypt_message(message, shared_secret)

            secure_message = {
                'encrypted_data': encrypted_data,
                'message_id': hashlib.sha256(message.encode()).hexdigest()[:16],
                'sender_node': self.node_id or 'unknown',
                'created_at': datetime.utcnow().isoformat()
            }

            # Add digital signature if requested
            if sign and self.private_key:
                signature_data = self.sign_message(message)
                secure_message['signature'] = signature_data

            logger.info("Secure message created successfully")
            return secure_message

        except Exception as e:
            logger.error(f"Secure message creation failed: {e}")
            raise

    def process_secure_message(self, secure_message: Dict[str, Any], shared_secret: bytes,
                               sender_public_key: Optional[ec.EllipticCurvePublicKey] = None) -> Dict[str, Any]:
        """
        Process and verify a received secure message

        Args:
            secure_message: Received secure message package
            shared_secret: Shared secret for decryption
            sender_public_key: Sender's public key for signature verification

        Returns:
            Dictionary containing decrypted message and verification status
        """
        try:
            # Decrypt the message
            decrypted_message = self.decrypt_message(
                secure_message['encrypted_data'],
                shared_secret
            )

            result = {
                'message': decrypted_message,
                'sender_node': secure_message.get('sender_node'),
                'message_id': secure_message.get('message_id'),
                'created_at': secure_message.get('created_at'),
                'signature_valid': None
            }

            # Verify signature if present
            if 'signature' in secure_message and sender_public_key:
                signature_valid = self.verify_signature(
                    secure_message['signature'],
                    sender_public_key
                )
                result['signature_valid'] = signature_valid

                if not signature_valid:
                    logger.warning("Message signature verification failed")

            logger.info("Secure message processed successfully")
            return result

        except Exception as e:
            logger.error(f"Secure message processing failed: {e}")
            raise

    def get_node_info(self) -> Dict[str, str]:
        """
        Get information about this ECC node

        Returns:
            Dictionary containing node information
        """
        return {
            'node_id': self.node_id or 'unknown',
            'curve': self.curve.name,
            'has_private_key': self.private_key is not None,
            'has_public_key': self.public_key is not None,
            'public_key_pem': self.get_public_key_pem() if self.public_key else None
        }