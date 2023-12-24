FROM hashicorp/terraform:1.6 as terraform

FROM python:3.12-bookworm as ansible

WORKDIR /ansible

COPY requirements.* /tmp/

RUN pip install -r /tmp/requirements.txt  \
    && ansible-galaxy install -r /tmp/requirements.yml  \
    && rm /tmp/requirements.*

COPY --chmod=755 entrypoint.yml /

COPY playbooks/*.yml ./

COPY --from=terraform /bin/terraform /bin/terraform

ENTRYPOINT [ "/entrypoint.yml" ]
