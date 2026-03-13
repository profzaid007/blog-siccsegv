# What is Cryptography? 
## Description: A look into the fundamental mechanism of cryptography
## Category: Cybersecurity

Cryptography is the practice of secure communication through the use of codes. It involves converting plaintext (readable) messages into ciphertext(unreadable) messages and back again, using mathematical algorithms called cryptographic protocols. Cryptography is a fundamental aspect of cybersecurity and is used to protect sensitive information from being accessed by unauthorized parties.

There are two main types of cryptographic techniques: 

* Symmetric-key cryptography 
* Public-key cryptography

Symmetric-key cryptography involves the use of the same key to both encrypt and decrypt the message. This means that both the sender and the recipient of the message must have the same key in order to communicate securely. One disadvantage of symmetric-key cryptography is that the key must be shared between the sender and the recipient, which can be problematic if the key is lost or stolen.

Public-key cryptography, on the other hand, involves the use of a public key to encrypt the message and a private key to decrypt it. The public keyis available to anyone, but the private key is only known to the owner. This means that anyone can send an encrypted message to the owner, but onlythe owner has the private key needed to decrypt the message. One advantage of public-key cryptography is that it allows for secure communication without the need to exchange a shared key.

Cryptography is used in a variety of applications in cybersecurity, including:

- Encrypting communications: Cryptography is used to secure communication channels, such as email and messaging apps, to ensure that only the intended recipient can read the message.

- Protecting data at rest: Cryptography is used to encrypt data stored on devices, such as laptops and smartphones, to prevent unauthorized access

- Securely storing passwords: Cryptographic hashing algorithms are used to store passwords in a secure manner, making it difficult for attackers to obtain the plaintext password even if they gain access to the hashed version.

There are many tools and techniques available for implementing cryptography, and choosing the right one depends on the specific needs of the application. Some common cryptographic algorithms and protocols include AES, RSA, and SSL/TLS.
