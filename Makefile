# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: crenault <crenault@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/02/13 15:36:50 by crenault          #+#    #+#              #
#    Updated: 2016/02/14 22:12:21 by crenault         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# glfw variables
GLFWNAME = glfw3
GLFWFOLDER = glfw
GLFWFOLDERLIB = glfwlib
GLFWLIB = lib$(GLFWNAME).a
GLFWLIBPATH = $(GLFWFOLDER)/$(GLFWLIB)
GLFWCHECK = $(GLFWFOLDER)/.git

# cMatrixHelper variables
CMHNAME = cmh
CMHFOLDER = cMatrixHelper
CMHLIB = lib$(CMHNAME).a
CMHLIBPATH = $(CMHFOLDER)/$(CMHLIB)
CMHCHECK = $(CMHFOLDER)/.git

# submodules
SUBMODCHECK = $(GLFWCHECK) $(CMHCHECK)
SUBMODEXIST = $(GLFWFOLDERLIB) $(CMHLIBPATH)

# libraries
LDFLAGSRAW = $(GLFWFOLDERLIB)/lib $(CMHFOLDER) $(CMHFOLDER)/libft
LDFLAGS = $(addprefix -L, $(LDFLAGSRAW))
LDLIBSRAW = $(GLFWNAME) $(CMHNAME) ft
LDLIBS = $(addprefix -l, $(LDLIBSRAW))

# compiler
CC = clang++

# executable name
NAME = particle-system

# flags
FLAGS = -Wall -Wextra
FLAGS += -std=c++11
# FLAGS += -Werror
FLAGS += -pedantic-errors
# FLAGS += -O3 -march=native
FLAGS += -g
# FLAGS += -Wpadded
# FLAGS += -fprofile-arcs -ftest-coverage

# include variables
INCLUDERAW = include include/load $(GLFWFOLDER)/include/GLFW
INCLUDERAW += $(CMHFOLDER)/include $(CMHFOLDER)/libft/includes
INCLUDE = $(addprefix -I, $(INCLUDERAW))

# frameworks
FRAMEWORKSRAW = OpenCL Cocoa OpenGL IOKit CoreVideo
FRAMEWORKS = $(addprefix -framework , $(FRAMEWORKSRAW))

# binary flags
CFLAGS = $(FLAGS) $(INCLUDE)

# to compile files
SRC = main.cpp
SRC += Window.cpp
SRC += Particles.cpp
SRC += pers_proj.cpp
SRC += get_file_content.cpp
SRC += load_shaders.cpp
SRC += load_kernel.cpp

# paths of source files
SRCDIR = src src/matrix src/load
vpath %.cpp $(SRCDIR)

# objects variables
OBJDIR = obj
OBJ = $(SRC:%.cpp=$(OBJDIR)/%.o)

# dependencies variables
DEPDIR = dep
DEP = $(SRC:%.cpp=$(DEPDIR)/%.d)

# .o files are secondary
.SECONDARY: $(OBJ)

# force rules and not file
.PHONY: all clean fclean re

# main rule
all: $(SUBMODCHECK) $(SUBMODEXIST) $(DEP) $(NAME)

# include dependencies generated
-include $(DEP)

# color variables
GREEN = "\033[0;32m"
BROWN = "\033[0;33m"
BLUE = "\033[0;34m"
RED = "\033[0;31m"
NO_COLOUR = "\033[0m"

# making compiled files
$(OBJDIR)/%.o: %.cpp | $(OBJDIR)
	@echo $(GREEN)"creation of" $@"..."$(NO_COLOUR)
	@$(CC) $(CFLAGS) -c -o $@ $<

# making dependencies files
$(DEPDIR)/%.d: %.cpp $(SUBMODCHECK) $(SUBMODEXIST) | $(DEPDIR)
	@echo $(BROWN)"creation of" $< "dependencies..."$(NO_COLOUR)
	@$(CC) $(CFLAGS) -MM $< -MT $(OBJDIR)/$*.o -MF $@

# making objs dir
$(OBJDIR):
	@mkdir -p $@

# making dependencies dir
$(DEPDIR):
	@mkdir -p $@

$(NAME): $(OBJ)
	@$(CC) -o $@ $^ $(FLAGS) $(LDFLAGS) $(LDLIBS) $(FRAMEWORKS)
	@echo $(BLUE)"created" $@$(NO_COLOUR)

# clean object files
clean:
	@$(RM) -r $(OBJDIR)
	@echo $(RED)$@ "done!"$(NO_COLOUR)

# clean exec files
fclean: clean
	@$(RM) $(NAME)
	@echo $(RED)$@ "done!"$(NO_COLOUR)

# rebuild
re: fclean all

# submodule check
$(SUBMODCHECK):
	@git submodule update --init --recursive
	@echo $(GREEN)"updated" $@$(NO_COLOUR)

# glfw compilation
$(GLFWFOLDERLIB):
	@cd $(GLFWFOLDER) && cmake -DGLFW_USE_CHDIR=OFF \
	-DCMAKE_INSTALL_PREFIX=../$(GLFWFOLDERLIB) -DGLFW_BUILD_EXAMPLES=OFF \
	-DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF .
	@make install -C $(GLFWFOLDER)
	@echo $@ "updated!"

# cMatrixHelper compilation
$(CMHLIBPATH):
	@$(MAKE) -C $(CMHFOLDER)
	@echo $@ "updated!"
