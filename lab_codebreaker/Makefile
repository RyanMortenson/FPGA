
# Add your rules here
background.mem: background.txt
	python3 ../lab_char/gen_initial_chars.py background.txt background.mem


clean:
	cd codebreaker; make clean
	cd codebreaker_top; make clean
	cd decrypt_rc4; make clean
	rm -f background.mem

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
