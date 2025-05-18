include .env
export $(shell sed 's/=.*//' .env)

.PHONY gcp-build:
gcp-build:
	docker build -t asia-northeast1-docker.pkg.dev/$(PROJECT_ID)/web-images/django-app -f ./docker/backend/Dockerfile ./backend

.PHONY gcp-push:
gcp-push:
	docker push asia-northeast1-docker.pkg.dev/$(PROJECT_ID)/web-images/django-app

.PHONY: gcp-deploy
gcp-deploy:
	gcloud run deploy django-app \
	--image asia-northeast1-docker.pkg.dev/$(PROJECT_ID)/web-images/django-app \
	--region asia-northeast1 \
	--platform managed \
	--allow-unauthenticated \
	--max-instances=1 \
	--env-vars-file=.env.yaml

.PHONY: generate-env-yaml


generate-env-yaml:
	@echo "" > .env.yaml
	@grep -v -e '^PORT=' -e '^#' -e '^$$' .env | while IFS='=' read -r key val; do \
		cleaned_val=$$(echo $$val | sed 's/^"\(.*\)"$$/\1/'); \
		echo "$$key: \"$$cleaned_val\"" >> .env.yaml; \
	done


.PHONY: deploy
deploy:
	@echo "Deploying to GCP..."
	@make gcp-build
	@make gcp-push
	@make generate-env-yaml
	@make gcp-deploy
	@echo "Deployment complete."