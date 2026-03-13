# What is the OSI Model?
## Description: The 7 layered framework for networking 
## Category: Programming

The OSI model can be defined as a theoretical blueprint that defines how computers communicate with their respective protocols on a network. Thoughthis model is used comparatively less in the practical world, it has its own benefits. This seven-layered model is often used to troubleshoot. The OSI model, with each layer dissecting the network communications systems, helps individuals and major companies trace the source of the problem and troubleshoot it.

The OSI model has the respective seven abstract layers:

(insert image of OSI model)

Typically, every time a data packet is sent from a terminal, it climbs up all the seven OSI stack layers and climbs them down again on the end users' side. And depending on what type of packet is being sent, their respective protocol is used.

7. Application layer
This layer involves the application a user interacts with. The application layer does not include the application itself but rather only the protocols the application uses. Give some examples http ftp.

6. presentation layer
This layer prepares the data for the application to use. The preparation includes encryption, decryption, character encodings, and compression. The presentation layer handles everything from decrypting the received data to encrypting it for the application to understand and send. This layer is mainly responsible for improving efficiency and usability for the user.

5. Session layer
From initializing a connection to terminating it, this layer manages it all. This is also the layer that reconnects when the current session is interrupted.

4. Transport layer
The host-to-host transport layer, also called the transport layer, consists of UDP and TCP. This layer is responsible for transferring data across a network.

3. Network layer
The network layer is the routing layer where the router, gateway, and all reside. This is the layer where the IP address and subnet mask are. again talk about how the ip is assigned 

2. Data-link layer
Mention how the mac address is assigned through NICs. This layer holds the protocols to communicate between physical devices and establishes and terminates communication in its interval. One such example would be the PPP. Switches lie here, along with MAC address and ARP(address resolution protocol).

1. Physical layer
Physical equipment like wires come under this layer. Data is converted to raw bit streams; these are received and transmitted in this layer.


