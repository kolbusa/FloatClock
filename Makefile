NAME = FloatClock
PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin
LAUNCH_AGENTS_DIR = $(HOME)/Library/LaunchAgents

PLIST = $(NAME).plist
INSTALLED_PLIST = $(LAUNCH_AGENTS_DIR)/$(PLIST)

.PHONY: install uninstall all clean register unregister

all: $(NAME)

$(NAME): $(NAME).swift
	swiftc $< -o $@

$(PLIST): $(PLIST).in
	cat $< | sed 's,@BIN_DIR@,$(BIN_DIR),g;s,@NAME@,$(NAME),g' > $@

clean:
	rm -f $(NAME) $(PLIST)

install: $(NAME) $(PLIST)
	install -m 755 $(NAME) $(BIN_DIR)
	install -m 644 $(PLIST) $(INSTALLED_PLIST)

uninstall: unregister
	rm -f $(NAME) $(INSTALLED_PLIST)

unregister:
	test -f $(INSTALLED_PLIST) && launchctl unload $(INSTALLED_PLIST) || true

register: install
	launchctl load $(INSTALLED_PLIST)
