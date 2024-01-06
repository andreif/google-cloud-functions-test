# Note: It expects env var PROJECT to be set before running make commands!
# Example:  PROJECT=my-project-123456  make setup deploy

REGION = europe-west1
FUNC = test-function


###  SETUP CLI

GCLOUD_IMG = gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine
GCLOUD_CONTAINER = gcloud
GCLOUD_EXEC = docker exec -ti ${GCLOUD_CONTAINER}
GCLOUD = ${GCLOUD_EXEC} gcloud
PLATFORM = $(shell uname -m | grep -q 'arm64' && echo '--platform linux/arm64')

setup:  auth  config-set  config-list
auth:  remove-existing-container
	docker run -ti ${PLATFORM} -v .:/app -w /app --name ${GCLOUD_CONTAINER} ${GCLOUD_IMG} gcloud auth login --brief
	docker start ${GCLOUD_CONTAINER}
remove-existing-container:
	@docker rm -f ${GCLOUD_CONTAINER} 2>/dev/null || true
config-set:
	test -n "${PROJECT}" || (echo "PROJECT env var not set"; exit 1)
	${GCLOUD} config set core/project ${PROJECT}
	${GCLOUD} config set functions/region ${REGION}
	@echo
	make config-list
config-list:
	${GCLOUD} config list


###  BUILD AND DEPLOY

deploy:
	${GCLOUD} functions deploy ${FUNC} --gen2 --trigger-http \
		--runtime=python312 --source=. --entry-point=handler \
		--project=${PROJECT} --region=${REGION}
