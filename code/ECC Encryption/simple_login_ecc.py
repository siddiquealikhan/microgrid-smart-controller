# simple_login_ecc.py
"""
Simple ECC Login System for Microgrid Project
Demonstrates ECC encryption for user login credentials
"""

import os
import base64
import json
from datetime import datetime
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF


class SimpleECCLogin:
    """Simple ECC system for login credential encryption"""

    def __init__(self):
        """Initialize the ECC login system"""
        self.private_key = None
        self.public_key = None
        self.generate_keys()

    def generate_keys(self):
        """Generate ECC key pair for login system"""
        print("🔐 Generating ECC keys for login system...")

        # Generate private key using SECP256R1 curve
        self.private_key = ec.generate_private_key(ec.SECP256R1())
        self.public_key = self.private_key.public_key()

        print("✅ ECC key pair generated successfully!")

    def encrypt_login_credentials(self, username, password):
        """
        Encrypt username and password using ECC

        Args:
            username: User's username
            password: User's password

        Returns:
            Dictionary with encrypted credentials
        """
        print(f"\n🔒 Encrypting login credentials for user: {username}")

        # Create login data
        login_data = {
            "username": username,
            "password": password,
            "timestamp": datetime.now().isoformat()
        }

        # Convert to JSON string
        login_json = json.dumps(login_data)

        # Generate a random symmetric key for AES encryption
        symmetric_key = os.urandom(32)  # 256-bit key

        # Encrypt the login data with AES
        iv = os.urandom(16)  # 128-bit IV
        cipher = Cipher(algorithms.AES(symmetric_key), modes.CBC(iv))
        encryptor = cipher.encryptor()

        # Pad the data
        login_bytes = login_json.encode('utf-8')
        padding_length = 16 - (len(login_bytes) % 16)
        padded_data = login_bytes + bytes([padding_length] * padding_length)

        # Encrypt the login data
        encrypted_login = encryptor.update(padded_data) + encryptor.finalize()

        # Sign the original login data for authenticity
        signature = self.private_key.sign(
            login_json.encode('utf-8'),
            ec.ECDSA(hashes.SHA256())
        )

        # Create the final encrypted package
        encrypted_package = {
            'encrypted_data': base64.b64encode(encrypted_login).decode('utf-8'),
            'iv': base64.b64encode(iv).decode('utf-8'),
            'symmetric_key': base64.b64encode(symmetric_key).decode('utf-8'),
            'signature': base64.b64encode(signature).decode('utf-8'),
            'algorithm': 'AES-256-CBC + ECDSA',
            'timestamp': datetime.now().isoformat()
        }

        print("✅ Login credentials encrypted successfully!")
        return encrypted_package

    def decrypt_login_credentials(self, encrypted_package):
        """
        Decrypt and verify login credentials

        Args:
            encrypted_package: Encrypted login data package

        Returns:
            Dictionary with decrypted login credentials
        """
        print("\n🔓 Decrypting login credentials...")

        try:
            # Extract components
            encrypted_data = base64.b64decode(encrypted_package['encrypted_data'])
            iv = base64.b64decode(encrypted_package['iv'])
            symmetric_key = base64.b64decode(encrypted_package['symmetric_key'])
            signature = base64.b64decode(encrypted_package['signature'])

            # Decrypt the login data
            cipher = Cipher(algorithms.AES(symmetric_key), modes.CBC(iv))
            decryptor = cipher.decryptor()
            padded_data = decryptor.update(encrypted_data) + decryptor.finalize()

            # Remove padding
            padding_length = padded_data[-1]
            login_json = padded_data[:-padding_length].decode('utf-8')

            # Verify signature
            self.public_key.verify(
                signature,
                login_json.encode('utf-8'),
                ec.ECDSA(hashes.SHA256())
            )

            # Parse the decrypted login data
            login_data = json.loads(login_json)

            print("✅ Login credentials decrypted and verified successfully!")
            return {
                'success': True,
                'username': login_data['username'],
                'password': login_data['password'],
                'timestamp': login_data['timestamp'],
                'signature_valid': True
            }

        except Exception as e:
            print(f"❌ Decryption failed: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def demo_login_system(self):
        """Demonstrate the ECC login system"""
        print("=" * 60)
        print("🚀 SIMPLE ECC LOGIN SYSTEM DEMO")
        print("=" * 60)

        # Demo credentials
        demo_username = "admin"
        demo_password = "microgrid123"

        print(f"Original Username: {demo_username}")
        print(f"Original Password: {demo_password}")

        # Encrypt the credentials
        encrypted_package = self.encrypt_login_credentials(demo_username, demo_password)

        print(f"\n📦 Encrypted Package Preview:")
        print(f"   Algorithm: {encrypted_package['algorithm']}")
        print(f"   Encrypted Data: {encrypted_package['encrypted_data'][:50]}...")
        print(f"   Signature: {encrypted_package['signature'][:50]}...")

        # Decrypt the credentials
        decrypted_result = self.decrypt_login_credentials(encrypted_package)

        if decrypted_result['success']:
            print(f"\n✅ DECRYPTION SUCCESSFUL!")
            print(f"   Decrypted Username: {decrypted_result['username']}")
            print(f"   Decrypted Password: {decrypted_result['password']}")
            print(f"   Signature Valid: {decrypted_result['signature_valid']}")
            print(f"   Timestamp: {decrypted_result['timestamp']}")
        else:
            print(f"\n❌ DECRYPTION FAILED!")
            print(f"   Error: {decrypted_result['error']}")

        print("=" * 60)
        return decrypted_result['success']


def main():
    """Main function to run the ECC login demo"""
    try:
        # Create ECC login system
        ecc_login = SimpleECCLogin()

        # Run the demonstration
        success = ecc_login.demo_login_system()

        if success:
            print("🎉 ECC Login System working perfectly!")
            print("💡 Your login credentials are now secured with ECC encryption!")
        else:
            print("⚠️ Something went wrong with the ECC system.")

    except Exception as e:
        print(f"❌ Error running ECC login demo: {e}")


if __name__ == "__main__":
    main()
