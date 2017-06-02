IMAGE:=alpine-static
TAR:=tar
OUT:=out
.PHONY: docker all
.DEFAULT:

UPXS:=tmux.stripped.up
TARGETS:=tmux tmux.stripped $(UPXS)
ALLTARGETS:=$(TARGETS)

all: $(ALLTARGETS)


upx: $(UPXS)

$(OUT):
	install -dm755 $@

dist: $(TARGETS) $(GHCTARGETS) static.tar.xz

static.tar.xz: upx
	(cd $(OUT) && tar cvf ../static.tar $(TARGETS) $(GHCTARGETS))
	xz -T0 -v9 static.tar

docker:
	sudo docker build -t $(IMAGE) .

$(TARGETS): docker $(OUT)
	sudo docker run -a stdout $(IMAGE) /bin/tar -cf - /usr/bin/$@ | $(TAR) xf - --strip-components=2 -C $(OUT)
	
$(GHCTARGETS): docker $(OUT)
	sudo docker run -a stdout $(IMAGE) /bin/tar -cf - /root/.cabal/bin/$@ | $(TAR) xf - --strip-components=3 -C $(OUT)

clean:
	-rm *.upx $(ALLTARGETS)

distclean: clean
	-rm static.tar.xz

dockerclean:
	sudo docker rmi -f $(IMAGE):latest
