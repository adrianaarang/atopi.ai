# Atajos de comandos: pipeline completo, tests, API y panel
.PHONY: pipeline test api

pipeline:
	python -m radiant.cli run --config configs/default.yaml

test:
	pytest

api:
	uvicorn api.main:app --reload
