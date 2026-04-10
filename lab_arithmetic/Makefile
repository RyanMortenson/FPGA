clean:
	cd full_add; make clean
	cd add_8; make clean
	cd arithmetic_top; make clean


################################# Passoff rules ################################
ENV_PATH = ../.venv/
IN_ENV = . $(ENV_PATH)/bin/activate;

$(ENV_PATH)/bin/activate:
	python3 -m venv $(ENV_PATH)
	$(IN_ENV) pip install -r ../requirements.txt

passoff_check: $(ENV_PATH)/bin/activate
	$(IN_ENV) python passoff.py

passoff_submit: $(ENV_PATH)/bin/activate
	$(IN_ENV) python passoff.py --submit