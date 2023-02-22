# matlab-coder-utils

This repo is meant to be used as a submodule for matlab projects. It provides support for these things:

* C++ versions of udp code. Without this a codegen of calls to dsp.udpReceiver/udpSender requires a matlab library which is only available on an OS for which matlab has application support. This means that you cannot compile this code on an Arm processor like a Raspberry pi. The C++ udp code in here provides codegen udp support for any posix platform. It is mainly meant to be used by uavrt_detection and airspy_channelize and is tailed to that.
* Header files for compiling codegen output on any posix platform. This is mainly used by the C++ udp code but should work for any generic codegen output.

To use the udp support you must do the following:

* Include matlab-coder-utils repo as a submodule of your matlab code repo.
* In the Matlab app Set Path to include matlab-coder-util/c-udp

## ComplexSingleSamplesUDPReceiver

This class is meant to be used to receive complex single precision samples from a udp port. 

Example usage:

```
% Setup the udp port for receiving
%   You specify the ip address and port
%   Last argument is max number of complex samples in a single udp packet
udpReceiver = ComplexSingleSamplesUDPReceiver("127.0.0.1", 10000, 1024);


% Read samples from the udp port
%   This call will not return until there is data available
complexSamples = udpReceiver.read()


% Clear out any data already existing on the udp port
udpRecevier.clear();

% Release the udp port
udpReceiver.release();
```

## ComplexSingleSamplesUDPSender

This class is meant to be used to send complex single precision samples from a udp port.

Example usage:

```
% Setup the udp port for receiving
%   You specify the ip address and port
%   Last argument is max number of complex samples in a single udp packet
udpSender = ComplexSingleSamplesUDPSender("127.0.0.1", 10000, 1024);


% Write samples to the udp port
udpSender.send(complexData);

% Release the udp port
udpSender.send();
```

## PulseInfoStruct

This class is meant to send and receive a PulseInfo matlab structure over udp. The PulseInfo structure is similar to the TunnelProtocol:PulseInfo_t structure in that it contains the same field. 

Example usage:

```
% Create an empty PulseInfoStruct
%   All values are set to NaN
pulseInfoStruct = PulseInfoStruct();

% Set values
pulseInfoStruct.tag_id          = 1;
pulseInfoStruct.frequency_hz    = 146000000;
...

% Setup and send the pulse info out over udp
pulseInfoStruct.udpSenderSetup("127.0.0.1", 10000);
pulseInfoStruct.sendOverUDP();

% Setup and receiver pulse over udp
%   After the receiveOverUDP call the pulseInfoStruct values will be set to what was received
%   dataAvailable:
%       true: data was readm struct values were updated
%       false: no data currently available, struct was not updated
dataAvailable = pulseInfoStruct.udpReceiverSetup("127.0.0.1", 10000);
pulseInfoStruct.receiveOverUDP();

```