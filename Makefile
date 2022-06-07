.PHONY: all
all: website

.PHONY: website
website: publish.el
	./make-site.sh

force-website:
	./make-site.sh t

deploy: website public
# NOTE: staging are must be empty, git stash maybe
	mkdir -p docs
	git checkout to-deploy
# NOTE: github pages only deploys to root or docs/
	rsync --archive public/ docs # NOTE: the slash in public/ matters!
	git add docs
	-git commit -m "Automated commit (this branch is for build artifacts only)"
# NOTE: Emacs `compile` won't work if the password is not cached (no
# interactive input allowed)
	git push --force origin to-deploy:gh-pages
	git checkout master
