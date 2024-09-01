################################################################################
# Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
################################################################################
#
# Makefile project only supported on Mac OS X and Linux Platforms)
#
################################################################################

# Attempt to compile a minimal application linked against FreeImage. If a.out exists, FreeImage is properly set up.
$(shell echo "#include \"FreeImage.h\"" > test.c; echo "int main() { return 0; }" >> test.c ; $(NVCC) $(ALL_CCFLAGS) $(INCLUDES) $(ALL_LDFLAGS) $(LIBRARIES) -l freeimage test.c)
FREEIMAGE := $(shell find a.out 2>/dev/null)
$(shell rm a.out test.c 2>/dev/null)

# Define the compiler and flags
NVCC = /usr/local/cuda/bin/nvcc
CXX = g++
CXXFLAGS = -std=c++11 -I/usr/local/cuda/include -Iinclude $(INCLUDES) -I/usr/local/include
LDFLAGS = -L/usr/local/cuda/lib64 -L/usr/local/lib -lcudart -lnppc -lnppial -lnppicc -lnppidei -lnppif -lnppig -lnppim -lnppist -lnppisu -lnppitc -lfreeimage

# Add CUDA path
CUDA_PATH ?= /usr/local/cuda
NPP_Lib ?= -lnppisu_static -lnppif_static -lnppc_static -lculibos -lfreeimage
#NPP_LIB  ?= -lnppif -lnppig -lnppc -lnppidei -lnppicc -lnppicom

# Adding appropriate NPP library flags
LDFLAGS += $(NPP_LIB)

# Add necessary include paths
INCLUDES = -ICommon -I$(CUDA_PATH) -Iinclude -ICommon/UtilNPP

# Add lib paths
LIBRARIES = -lnppisu_static -lnppif_static -lnppc_static -lculibos -lfreeimage

# Define directories
SRC_DIR = src
BIN_DIR = bin
DATA_DIR = data
LIB_DIR = lib
OUTPUT_DIR = $(DATA_DIR)/outputs


# Define source files and target executable
SRC = $(SRC_DIR)/edgeDetectionNPP.cpp
TARGET = $(BIN_DIR)/edgeDetectionNPP

# Define the default rule
all: $(TARGET)

# Rule for building the target executable
$(TARGET): $(SRC)
	mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

# Rule for running the application (loops through jpg/jpeg images in data folder)
run: $(TARGET)
	mkdir -p $(OUTPUT_DIR)
	for file in $(DATA_DIR)/*.jpg $(DATA_DIR)/*.jpeg; do \
		[ -e "$$file" ] || continue; \
		filename=$$(basename "$$file"); \
		./$(TARGET) --input "$$file" --output $(OUTPUT_DIR)/"$${filename%.*}_output.jpg"; \
	done

# Clean up
clean:
	rm -rf $(BIN_DIR)/*

# Installation rule (not much to install, but here for completeness)
install:
	@echo "No installation required."

# Help command
help:
	@echo "Available make commands:"
	@echo "  make        - Build the project."
	@echo "  make run    - Run the project."
	@echo "  make clean  - Clean up the build files."
	@echo "  make install- Install the project (if applicable)."
	@echo "  make help   - Display this help message."