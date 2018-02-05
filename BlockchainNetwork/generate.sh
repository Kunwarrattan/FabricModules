#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=mychannel

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

#  export path=/home/kicki/go/BlockchainNetwork/bin:$PATH
#  cryptogen generate --config=crypto-config.yaml
#  
#  export FABRIC_CFG_PATH=$PWD
#  configtxgen -profile FourOrgsOrdererGenesis -outputBlock channel-artifacts/genesis.block
#
#  mkdir channel-artifacts
#  configtxgen -profile FourOrgsOrdererGenesis -outputBlock channel-artifacts/genesis.block
#
#  CHANNEL_NAME=NodeChannels  && configtxgen -profile FiveOrgsChannel -outputCreateChannelTx channel-artifacts/channel.tx -channelID NodeChannels
#  CHANNEL_NAME=NodeChannels  && configtxgen -profile FiveOrgsChannel -outputCreateChannelTx channel-artifacts/channel.tx -channelID NodeChannels
#  
#  configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate channel-artifacts/Org1MSPanchors.tx -channelID NodeChannels -asOrg Org1MSP
#  configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate channel-artifacts/Org2MSPanchors.tx -channelID NodeChannels -asOrg Org2MSP
#  configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate channel-artifacts/Org3MSPanchors.tx -channelID NodeChannels -asOrg Org3MSP
#  configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate channel-artifacts/Org4MSPanchors.tx -channelID NodeChannels -asOrg Org4MSP
#  configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate channel-artifacts/Org5MSPanchors.tx -channelID NodeChannels -asOrg Org5MSP