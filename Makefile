# Install the application remotely
install: install-ansible install-application

# Install the application locally
install-local: install-apt-packages install-rust install-ansible

# Install the required system packages with apt
# TODO: Suppress apt-get update output
install-apt-packages:
	@echo "Installing system packages..."
	@sudo DEBIAN_FRONTEND=noninteractive apt-get --quiet=2 update
	@sudo DEBIAN_FRONTEND=noninteractive apt-get --quiet=2 install python3-venv


# Install Rust
install-rust:
	@echo "Installing the Rust toolchain..."
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh -s -- --quiet


# Install the application using Ansible installation logic
install-ansible: install-ansible-venv install-ansible-requirements


# Create a Python virtual environment for Ansible installation logic
install-ansible-venv:
	@echo "Setting up a virtual environment..."
	@python3 -m venv install/ansible/venv


# Install requirements for Ansible installation logic
install-ansible-requirements:
	@echo "Installing Ansible..."
	@. install/ansible/venv/bin/activate && \
		pip install --disable-pip-version-check --quiet --requirement ./install/ansible/requirements.txt


# Run the Ansible installation logic playbook remotely
install-application:
	@echo "Running installation playbook..."
	@read -p "Enter hostname or IP adddress for Raspberry Pi: [raspberrypi]" remote_hostname && \
	 remote_hostname=$${remote_hostname:-raspberrypi} && \
	 read -p "Enter SSH username for Raspberry Pi: [pi]" remote_username && \
	 remote_username=$${remote_username:-pi} && \
	 ssh-copy-id $$remote_username@$$remote_hostname > /dev/null 2>&1 && \
	 . install/ansible/venv/bin/activate && \
	 ansible-playbook --inventory $$remote_hostname, --user $$remote_username install/ansible/install-ntag-pi.yml


# Run the Ansible installation logic playbook locally
install-application-local:
	@echo "Running installation playbook..."
	@. install/ansible/venv/bin/activate; \
		ansible-playbook --connection local --inventory localhost, install/ansible/install-ntag-pi.yml


# Run tests on the repository
test: test-install test-backend


# Test the installation logic
test-install: test-install-ansible


# Test Ansible installation logic
test-install-ansible: test-install-ansible-venv test-install-ansible-requirements test-install-ansible-lint


# Create a Python virtual environment for Ansible installation logic tests
test-install-ansible-venv:
	@python3 -m venv install/ansible/venv-test


# Install requirements for Ansible installation logic tests
test-install-ansible-requirements:
	@. install/ansible/venv-test/bin/activate && \
		pip install --disable-pip-version-check --quiet --requirement install/ansible/requirements-test.txt


# Run Ansible Lint over Ansible installation logic
test-install-ansible-lint:
	@. install/ansible/venv-test/bin/activate && \
		ansible-lint install/ansible/install-ntag-pi.yml


# Test the backend
test-backend: test-backend-python


# Test backend Python code
test-backend-python: test-backend-python-venv test-backend-python-pip test-backend-python-pylama


# Create a Python virtual environment for backend tests
test-backend-python-venv:
	@python3 -m venv backend/venv-test


# Install requirements for Python code tests
test-backend-python-pip:
	@. backend/venv-test/bin/activate && \
		pip install --disable-pip-version-check --quiet --requirement backend/requirements-test.txt


test-backend-python-pylama:
	@. backend/venv-test/bin/activate && \
		pylama backend/src
