# Add your rules here

mymessage.mem: mymessage.txt
	python3 gen_initial_chars.py mymessage.txt mymessage.mem

clean:
	cd char_gen; make clean
	cd char_gen_top; make clean 
	rm -f mymessage.mem

################################# Passoff rules ################################
ENV_PATH = ../../.venv/
IN_ENV = . $(ENV_PATH)/bin/activate;

$(ENV_PATH)/bin/activate:
	python3 -m venv $(ENV_PATH)
	$(IN_ENV) pip install -r ../../requirements.txt

passoff_check: $(ENV_PATH)/bin/activate
	$(IN_ENV) python passoff.py

passoff_submit: $(ENV_PATH)/bin/activate
	$(IN_ENV) python passoff.py --submit
