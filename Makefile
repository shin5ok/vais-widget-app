
NAME := chatui-using-answerapi


.PHONY: deploy
deploy:
	@echo "Building Cloud Run service of chatapp-answer-api"

	gcloud beta run deploy chatapp-answer-api \
	--source=. \
	--region=asia-northeast1 \
	--cpu=1 \
	--memory=1G \
	--ingress=internal-and-cloud-load-balancing \
	--set-env-vars=SUBJECT="$(SUBJECT)",REF_PAGES=$(REF_PAGES),REF_ONLY=$(REF_ONLY),DATASTORE_ID=$(DATASTORE_ID),PROJECT_ID=$(PROJECT_ID) \
	--min-instances=1 \
	--no-default-url \
	--service-account=chatapp-answer-api@$(PROJECT_ID).iam.gserviceaccount.com \
	--session-affinity \
	--cpu-boost \
	--allow-unauthenticated

.PHONY: sa
sa:
	@echo "Make service accounts"

	gcloud iam service-accounts create chatapp-answer-api
	gcloud iam service-accounts create cloudbuild


.PHONY: iam
CLOUDBUILD_SA:=$(shell gcloud builds get-default-service-account | grep gserviceaccount | cut -d / -f 4)
iam: sa
	@echo "Grant some authorizations to the service account for Cloud Run service"

	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	--member=serviceAccount:chatapp-answer-api@$(PROJECT_ID).iam.gserviceaccount.com \
	--role=roles/discoveryengine.editor

	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	--member=serviceAccount:chatapp-answer-api@$(PROJECT_ID).iam.gserviceaccount.com \
	--role=roles/storage.objectUser

	@echo "Grant some authorizations to the service account for Cloud Build"

	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	--member=serviceAccount:$(CLOUDBUILD_SA) \
	--role=roles/artifactregistry.repoAdmin

	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	--member=serviceAccount:$(CLOUDBUILD_SA) \
	--role=roles/cloudbuild.builds.builder

	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	--member=serviceAccount:$(CLOUDBUILD_SA) \
	--role=roles/run.admin

	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	--member=serviceAccount:$(CLOUDBUILD_SA) \
	--role=roles/storage.admin

.PHONY: run
run:
	docker run -it -v $(HOME):/root -p 8000:8080 -e PROJECT_ID=$(PROJECT_ID) -e DATASTORE_ID=$(DATASTORE_ID) $(NAME)

.PHONY: local-build
local-build:
	docker build -t $(NAME) .
