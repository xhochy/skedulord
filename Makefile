flake:
	flake8 skedulord
	flake8 tests
	flake8 setup.py

install:
	pip install -e ".[dev]"

develop: install
	python setup.py develop

test:
	pytest --cov=skedulord tests

check: flake test clean

clean:
	rm -rf .pytest_cache
	rm -rf build
	rm -rf dist
	rm -rf scikit_lego.egg-info
	rm -rf .ipynb_checkpoints
	rm -rf notebooks/.ipynb_checkpoints
	rm -rf skedulord.egg-info

dev:
	cd skedulord/dashboard && gatsby build
	cp -r skedulord/dashboard/public/* skedulord/web/templates
	cd skedulord/dashboard && gatsby clean
	lord serve

reset:
	lord init
	lord nuke --yes --really
	lord init
	lord run pyjob "python jobs/pyjob.py" --retry 1 --wait 1
	lord run pyjob "python jobs/badpyjob.py" --retry 3 --wait 1

test-frontend:
	lord serve & ./node_modules/.bin/cypress run

test-gitlab:
	gitlab-runner exec docker test

push: build reset test-frontend
	rm -rf dist
	python setup.py sdist
	python setup.py bdist_wheel --universal
	twine upload dist/*
