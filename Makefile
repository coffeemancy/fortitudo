## Environment variables
#
# There are a number of environment variables which can be overriden for local
# use. In that case, simply use `make -e` to use overrides with `make`.
#
BUNDLE_OPTS=--without=development
RBENV_VERSION=2.1.6

# just running `make` or `make all` will do `make test`
all: test

## Cleanup
#
# Running `make clean` will clean up ruby cruft,
# yielding a clean development and testing environment.
#
clean: clean/rbenv clean/bundle

# clean out bundle, if needed
clean/bundle: clean/rbenv
	bundle check || \
	bundle $(BUNDLE_OPTS) || \
	bundle clean --force || \
	rm -f Gemfile.lock

# only set up rbenv if rbenv is installed
clean/rbenv:
	if [ `which rbenv` ]; then \
		rbenv local $(RBENV_VERSION) || \
			(rbenv install $(RBENV_VERSION) && \
			rbenv local $(RBENV_VERSION)) && \
		rbenv exec gem install bundler --no-ri --no-rdoc && \
		rbenv rehash; \
	fi

# bundle without development stuff
bundle: clean/rbenv
	bundle $(BUNDLE_OPTS)

# tests
test: clean bundle test/style

### Style testing
#
test/style: test/flay test/reek test/rubocop

style: test/style

# run flay from `rake` task
test/flay: bundle
	bundle exec rake style:flay

# run reek from `rake` task
test/reek: bundle
	bundle exec rake style:reek

# run rubocop from `rake` task
test/rubocop: bundle
	bundle exec rake style:rubocop
