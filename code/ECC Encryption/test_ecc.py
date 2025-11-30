# test_ecc.py

from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes

# Generate ECC key pair
private_key = ec.generate_private_key(ec.SECP256R1())
public_key = private_key.public_key()

# Sign a message
message = b"Test ECC!"
signature = private_key.sign(message, ec.ECDSA(hashes.SHA256()))

# Verify the signature
public_key.verify(signature, message, ec.ECDSA(hashes.SHA256()))
print("ECC key pair, sign, verify: SUCCESS")
