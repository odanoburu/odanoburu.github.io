.PHONY: all
all: website

.PHONY: blog
website:
	./make-site.sh

force-website:
	./make-site.sh t

deploy: website public
	git checkout to-deploy
# NOTE: github pages only deploys to root or docs/
	rsync --archive public/ docs # NOTE: the slash in public/ matters!
	git add docs
	-git commit -m "deploy"
	git push --force origin to-deploy:gh-pages
	git checkout master
