RM=rm -rf
CP=cp -rf

chen:=1
ifeq ($(chen), 1)
CHEN:=export wolffy=1;
endif

#C=gcc
CXX=g++ -std=c++11 -Wl,-Bsymbolic -Wl,--version-script=chen.ver
CXXFLAGS+=-Wall -Wfatal-errors -g -O3 -fPIC -DNDEBUG -fmessage-length=0 -shared/-static -fopenmp
MYFLAGS=$(CXXFLAGS) -DMSGINFO=1

ROOT_PATH?=/home/chen

SYS_INCLUDE=$(ROOT_PATH)/include
SYS_LIB=$(ROOT_PATH)/lib

INCLUDES=-I. -I $(SRC_INCLUDE) -I $(SYS_INCLUDE)

LDFLAGS+=-L. -L$(SYS_LIB)
LIBRARIES=-Wl,--whole-archive,-Bstatic -lchen -Wl,--no-whole-archive,-Bdynamic \
		-ldl -lrt -Wl,--whole-archive -lpthread -Wl,--no-whole-archive


MYFLAGS+=$(INCLUDES)
LDFLAGS+=$(LIBRARIES)


#source code dir
PROJECT_DIR=.
BIN_DIR=.
SRC_DIR=src
SRC_INCLUDE=$(SRC_DIR)

CPP_SRC:=$(SRC_DIR)/main.cpp \
		$(wildcard $(SRC_DIR)/chen/*.cpp)
C_SRC:=$(SRC_DIR)/main.c \
		$(wildcard $(SRC_DIR)/chen/*.c)

#objects
OUT_DIR=build
CPP_O=$(CPP_SRC:%.cpp=$(OUT_DIR)/%.cpp.o)
C_O=$(C_SRC:%.c=$(OUT_DIR)/%.c.o)
ALL_O=$(CPP_O) $(C_O)

#source dependency
CPP_DEPS=$(CPP_SRC:%.cpp=$(OUT_DIR)/%.cpp.d)
C_DEPS=$(C_SRC:%.c=$(OUT_DIR)/%.c.d)
ALL_DEPS=$(CPP_DEPS) $(C_DEPS)

#target
TARGET=main
ALL=$(TARGET)

all:$(ALL)

#clean the project all
clean:
	@echo "clean ...";
	@$(RM) $(OUT_DIR) $(TARGET)

#source sub directories
SUB_DIRS=$(shell find $(SRC_DIR) -type d)

#rule for make the dir
dirs:
	mkdir -p $(OUT_DIR);
	for val in $(SUB_DIRS);do \
		mkdir -p $(OUT_DIR)/$${val}; \
	done

#link rules for target
$(TARGET):$(ALL_O)
		$(CXX) $(MYFLAGS) $(ALL_O) $(LDFLAGS) -o $(addprefix $(OUT_DIR)/,$@)
		$(CP) $(OUT_DIR)/$(TARGET) $(BIN_DIR)
		#strip $(BIN_DIR)/$(TARGET)

#compile dependency
$(OUT_DIR)/%.cpp.o:%.cpp
		$(CXX) $(MYFLAGS) -c $< -o $@
		#$(CXX) $(MYFLAGS) -MMD -MP -MF "$(@:%.o=%.d)" -c $< -o $@
$(OUT_DIR)/%.c.o:%.c
		$(C) $(MYFLAGS) -c $< -o $@
		#$(C) $(MYFLAGS) -MMD -MP -MF "$(@:%.o=%.d)" -c $< -o $@

#generate dependency rules
-include $(ALL_DEPS)
$(OUT_DIR)/%.cpp.d:%.cpp
		@if [ ! -d $(shell dirname $@) ]; then mkdir -p $(shell dirname $@); fi;
		@set -e; rm -f $@; \
		$(CXX) $(MYFLAGS) -MM -MP -MT $(@:%.d=%.o) $< > $@.$$$$; \
		sed 's,\($*\)\.cpp.o[ :]*,\1.cpp.o $@ : ,g' < $@.$$$$ > $@; \
		rm -f $@.$$$$
$(OUT_DIR)/%.c.d:%.c
		@if [ ! -d $(shell dirname $@) ]; then mkdir -p $(shell dirname $@); fi;
		@set -e; rm -f $@; \
		$(C) $(MYFLAGS) -MM -MP -MT $(@:%.d=%.o) $< > $@.$$$$; \
		sed 's,\($*\)\.c.o[ :]*,\1.c.o $@ : ,g' < $@.$$$$ > $@; \
		rm -f $@.$$$$

.PHONY: all clean dirs

