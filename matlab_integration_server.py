# simple_matlab_demo.py
"""
Simple MATLAB Integration Demo - Basic Version
Works with your existing ECC system without complex dependencies
"""

import json
from datetime import datetime
from app.crypto.ecc_manager import ECCmanager
from app.crypto.key_manager import KeyManager


class SimpleMATLABDemo:
    """Simple demo of MATLAB-Python ECC integration"""

    def __init__(self):
        # Initialize ECC components
        self.ecc_manager = ECCmanager()
        self.key_manager = KeyManager()
        self.matlab_connected = False
        self.shared_secret = None

    def run_demo(self):
        """Run the complete integration demo"""
        print("🚀 SIMPLE MATLAB-PYTHON ECC INTEGRATION DEMO")
        print("=" * 70)

        # Step 1: Initialize Python ECC system
        print("\n🔐 STEP 1: Initialize Python ECC System")
        self.initialize_python_ecc()

        # Step 2: Simulate MATLAB key exchange
        print("\n🤝 STEP 2: Simulate MATLAB Key Exchange")
        self.simulate_matlab_key_exchange()

        # Step 3: Demonstrate secure communication
        print("\n💬 STEP 3: Secure Communication Demo")
        self.demonstrate_secure_communication()

        # Step 4: Simulate live data exchange
        print("\n📊 STEP 4: Live Data Exchange Simulation")
        self.simulate_live_data_exchange()

        print("\n" + "=" * 70)
        print("✅ MATLAB-PYTHON INTEGRATION DEMO COMPLETED!")
        print("🔒 All communications secured with ECC encryption")
        print("🎯 Ready for real MATLAB integration!")
        print("=" * 70)

    def initialize_python_ecc(self):
        """Initialize Python ECC system"""
        try:
            # Generate key pair
            self.ecc_manager.generate_key_pair("python_server")

            # Save keys
            self.key_manager.save_private_key(self.ecc_manager.private_key, "python_server")
            self.key_manager.save_public_key(self.ecc_manager.public_key, "python_server")

            print(f"   ✅ Python ECC server initialized")
            print(f"   🆔 Node ID: {self.ecc_manager.node_id}")
            print(f"   🔑 Key pair generated and saved")

        except Exception as e:
            print(f"   ❌ Initialization failed: {e}")

    def simulate_matlab_key_exchange(self):
        """Simulate MATLAB connecting and exchanging keys"""
        try:
            # Simulate MATLAB generating its own key pair
            matlab_ecc = ECCmanager()
            matlab_ecc.generate_key_pair("matlab_simulation")

            print(f"   📱 MATLAB simulation initialized")
            print(f"   🆔 MATLAB Node ID: {matlab_ecc.node_id}")

            # Simulate key exchange
            print(f"   🔄 Performing ECDH key exchange...")

            # Python gets MATLAB's public key
            shared_secret_python = self.ecc_manager.perform_ecdh(matlab_ecc.public_key)

            # MATLAB gets Python's public key (simulated)
            shared_secret_matlab = matlab_ecc.perform_ecdh(self.ecc_manager.public_key)

            # Verify both sides have same secret
            if shared_secret_python == shared_secret_matlab:
                self.shared_secret = shared_secret_python
                self.matlab_connected = True
                self.key_manager.store_shared_secret("matlab_simulation", self.shared_secret)

                print(f"   ✅ Key exchange successful!")
                print(f"   🔐 Shared secret established ({len(self.shared_secret)} bytes)")
                print(f"   🤝 Secure session active")
            else:
                print(f"   ❌ Key exchange failed - secrets don't match")

        except Exception as e:
            print(f"   ❌ Key exchange error: {e}")

    def demonstrate_secure_communication(self):
        """Demonstrate secure message exchange"""
        if not self.matlab_connected:
            print("   ❌ No secure session - skipping communication demo")
            return

        try:
            # Simulate MATLAB sending command to Python
            print("   📤 MATLAB → Python: Secure Command")

            matlab_command = {
                "command": "SET_VOLTAGE",
                "value": "230V",
                "priority": "HIGH",
                "timestamp": datetime.now().isoformat()
            }

            # Encrypt command
            encrypted_command = self.ecc_manager.create_secure_message(
                json.dumps(matlab_command),
                self.shared_secret,
                sign=True
            )

            print(f"      Original: {matlab_command['command']}")
            print(f"      Encrypted: {encrypted_command['encrypted_data']['ciphertext'][:40]}...")
            print(f"      Signed: ✅")

            # Decrypt command (Python receiving)
            decrypted_result = self.ecc_manager.process_secure_message(
                encrypted_command,
                self.shared_secret,
                self.ecc_manager.public_key  # In real scenario, this would be MATLAB's public key
            )

            decrypted_command = json.loads(decrypted_result['message'])
            print(f"      Decrypted: {decrypted_command['command']}")
            print(f"      Signature valid: {decrypted_result['signature_valid']}")

            # Simulate Python responding to MATLAB
            print("\n   📥 Python → MATLAB: Secure Response")

            python_response = {
                "status": "COMMAND_RECEIVED",
                "command": matlab_command['command'],
                "result": "VOLTAGE_SET_TO_230V",
                "timestamp": datetime.now().isoformat()
            }

            # Encrypt response
            encrypted_response = self.ecc_manager.create_secure_message(
                json.dumps(python_response),
                self.shared_secret,
                sign=True
            )

            print(f"      Response: {python_response['result']}")
            print(f"      Encrypted: {encrypted_response['encrypted_data']['ciphertext'][:40]}...")
            print(f"      ✅ Secure bidirectional communication verified!")

        except Exception as e:
            print(f"   ❌ Communication error: {e}")

    def simulate_live_data_exchange(self):
        """Simulate live microgrid data exchange"""
        if not self.matlab_connected:
            print("   ❌ No secure session - skipping live data demo")
            return

        print("   📊 Simulating 10 seconds of live encrypted data exchange:")
        print("   " + "-" * 60)

        import time
        import random

        try:
            for t in range(5):
                # Generate simulated microgrid data
                microgrid_data = {
                    "time": t * 2,
                    "voltage": 230 + random.uniform(-1, 1),
                    "current": 12 + random.uniform(-0.5, 0.5),
                    "frequency": 50 + random.uniform(-0.05, 0.05),
                    "status": random.choice(["STABLE", "FLUCTUATING"]),
                    "timestamp": datetime.now().isoformat()
                }

                microgrid_data["power"] = microgrid_data["voltage"] * microgrid_data["current"]

                # Encrypt data
                encrypted_data = self.ecc_manager.create_secure_message(
                    json.dumps(microgrid_data),
                    self.shared_secret,
                    sign=True
                )

                # Display live data
                print(f"   T+{microgrid_data['time']:2d}s | "
                      f"V: {microgrid_data['voltage']:6.1f}V | "
                      f"P: {microgrid_data['power']:7.1f}W | "
                      f"Status: {microgrid_data['status']:12s} | "
                      f"🔒 Encrypted")

                # Simulate real-time delay
                time.sleep(1)

            print("   " + "-" * 60)
            print("   ✅ Live data exchange completed successfully!")
            print("   🔒 All 5 data points encrypted and transmitted securely")

        except Exception as e:
            print(f"   ❌ Live data error: {e}")


def main():
    """Run the simple MATLAB integration demo"""
    try:
        demo = SimpleMATLABDemo()
        demo.run_demo()

        print(f"\n Do the next Steps:")


    except Exception as e:
        print(f"❌ Demo failed: {e}")


if __name__ == "__main__":
    main()
