%
% Copyright (c) 2018 Anol Paisal <info@emone.co.th>
% All rights reserved.
% Distributed under the terms of the MIT License. See the LICENSE file.
%
% The 'Solar Panel Sensors GPS Demo' application from the SCLoRa Demo Kit
%
-module(lorawan_application_sclora_mote).
-behaviour(lorawan_application).

-export([init/1, handle_join/3, handle_uplink/4, handle_rxq/5, handle_delivery/3]).

-include("lorawan.hrl").
-include("lorawan_db.hrl").

init(_App) ->
    ok.

handle_join({_Network, _Profile, _Device}, {_MAC, _RxQ}, _DevAddr) ->
    % accept any device
    ok.

handle_uplink({_Network, _Profile, _Node}, _RxQ, {missed, _Receipt}, _Frame) ->
    retransmit;
handle_uplink(_Context, _RxQ, _LastMissed, _Frame) ->
    % accept and wait for deduplication
    {ok, []}.

% the data structure is explained in
% https://github.com/Lora-net/LoRaMac-node/blob/master/src/apps/LoRaMac/classA/LoRaMote/main.c#L207
handle_rxq({_Network, _Profile, #node{devaddr=DevAddr}}, _Gateways, _WillReply,
        #frame{port=2, data= <<LUX:16, Ex_Temp:16, Humi:16, Press:16, Lat:24, Lon:24, AltGps:16, Volt:16, Amp:16, PowConsump:16, Batt, Rain, RainLVL:16, Energ:16, PowPanel:16, In_Temp:16, Err:32>>}, []) ->
    % this is used in AS923
    lager:debug("PUSH_DATA ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w ~w",[_Gateways, DevAddr, LUX, Ex_Temp, Humi, Press, Lat, Lon, AltGps ,Volt, Amp, PowConsump, Batt, Rain, RainLVL, Energ, PowPanel, In_Temp, Err]),
    % blink with the LED indicator
    {send, #txdata{port=2, data= <<Err>>}};
handle_rxq(_Context, _Gateways, _WillReply, #frame{port=Port, data=Data}, []) ->
    {error, {not_sclora_mote, {Port, Data}}}.

handle_delivery({_Network, _Profile, _Node}, _Result, _Receipt) ->
    ok.

% end of file
