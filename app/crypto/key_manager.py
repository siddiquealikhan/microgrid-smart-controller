# app/crypto/key_manager.py
"""
Key Manager - Simple ECC Key Storage and Management
"""

import os
import json
import base64
import logging
from datetime import datetime, timedelta
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import serialization

logger = logging.getLogger(__name__)


class KeyManager:
    """Simple key manager for ECC keys and shared secrets"""

    def __init__(self, key_storage_path="keys"):
        """Initialize Key Manager"""
        self.key_storage_path = key_storage_path
        self.shared_secrets = {}
        self.node_keys = {}

        # Create directory if it doesn't exist
        os.makedirs(key_storage_path, exist_ok=True)
        logger.info(f"Key Manager initialized: {key_storage_path}")

    def save_private_key(self, private_key, node_id, password=None):
        """Save private key to file"""
        try:
            key_filename = f"{node_id}_private.pem"
            key_path = os.path.join(self.key_storage_path, key_filename)

            if password:
                encryption = serialization.BestAvailableEncryption(password.encode())
            else:
                encryption = serialization.NoEncryption()

            pem = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=encryption
            )

            with open(key_path, 'wb') as f:
                f.write(pem)

            logger.info(f"Private key saved for node: {node_id}")
            return key_path

        except Exception as e:
            logger.error(f"Failed to save private key: {e}")
            raise

    def save_public_key(self, public_key, node_id):
        """Save public key to file"""
        try:
            key_filename = f"{node_id}_public.pem"
            key_path = os.path.join(self.key_storage_path, key_filename)

            pem = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )

            with open(key_path, 'wb') as f:
                f.write(pem)

            # Cache the key
            self.node_keys[node_id] = public_key

            logger.info(f"Public key saved for node: {node_id}")
            return key_path

        except Exception as e:
            logger.error(f"Failed to save public key: {e}")
            raise

    def load_public_key_from_pem(self, pem_data):
        """Load public key from PEM string"""
        try:
            public_key = serialization.load_pem_public_key(pem_data.encode('utf-8'))
            return public_key
        except Exception as e:
            logger.error(f"Failed to load public key from PEM: {e}")
            raise

    def store_shared_secret(self, node_id, shared_secret, expires_in_hours=24):
        """Store shared secret with expiration"""
        try:
            expiry_time = datetime.utcnow() + timedelta(hours=expires_in_hours)

            secret_data = {
                'secret': base64.b64encode(shared_secret).decode('utf-8'),
                'created_at': datetime.utcnow().isoformat(),
                'expires_at': expiry_time.isoformat(),
                'partner_node': node_id
            }

            self.shared_secrets[node_id] = secret_data
            logger.info(f"Shared secret stored for node: {node_id}")

        except Exception as e:
            logger.error(f"Failed to store shared secret: {e}")
            raise

    def get_shared_secret(self, node_id):
        """Get shared secret if not expired"""
        try:
            if node_id not in self.shared_secrets:
                logger.warning(f"No shared secret found for node: {node_id}")
                return None

            secret_data = self.shared_secrets[node_id]
            expiry_time = datetime.fromisoformat(secret_data['expires_at'])

            if datetime.utcnow() > expiry_time:
                logger.warning(f"Shared secret expired for node: {node_id}")
                del self.shared_secrets[node_id]
                return None

            shared_secret = base64.b64decode(secret_data['secret'])
            return shared_secret

        except Exception as e:
            logger.error(f"Failed to retrieve shared secret: {e}")
            return None

    def get_status(self):
        """Get key manager status"""
        try:
            return {
                'storage_path': self.key_storage_path,
                'active_shared_secrets': len(self.shared_secrets),
                'cached_public_keys': len(self.node_keys)
            }
        except Exception as e:
            logger.error(f"Failed to get status: {e}")
            return {'error': str(e)}


class Key:
    pass