########## Rules ###############################

about:
	cat aboutme.txt

reverse:
	rev aboutme.txt > reverse.txt

bottom:
	tail -n 3 aboutme.txt > bottom.txt

clean:
	rm -f reverse.txt bottom.txt

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

