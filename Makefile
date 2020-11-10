STACK_OPERATION ?= update-stack
COMMIT_SHA := $$(git log --pretty=format:'%h' -n 1)
OUTPUT_FILE := package.yaml
STACK_NAME := config-setup
S3_BUCKET := dh-deploys

package:
	aws cloudformation package --template-file config/root.yaml --s3-bucket ${S3_BUCKET} --s3-prefix ${COMMIT_SHA} --output-template-file ${OUTPUT_FILE}
	aws s3 mv ${OUTPUT_FILE} s3://${S3_BUCKET}/${COMMIT_SHA}/${OUTPUT_FILE}
deploy: package
	aws cloudformation ${STACK_OPERATION} --stack-name ${STACK_NAME} --template-url https://s3.amazonaws.com/${S3_BUCKET}/${COMMIT_SHA}/${OUTPUT_FILE} --capabilities CAPABILITY_NAMED_IAM
