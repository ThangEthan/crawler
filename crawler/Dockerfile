FROM python

WORKDIR /root

COPY files/requirements.txt .

ENV PATH="/root:${PATH}"

RUN pip install --upgrade pip; \
pip install -r requirements.txt; \
apt-get update; apt-get install default-mysql-client zsh links2 lynx jq -y; \
mkdir house; \
touch house/link.txt house/some_random_house.html;

COPY files .
CMD tail -f autorun.sh
