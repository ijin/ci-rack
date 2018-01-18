#!/bin/bash
set -x

eval $(aws --region ap-northeast-1 ecr get-login --no-include-email)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text | awk '{print $1}')
export SHA1=`echo ${CIRCLE_SHA1} | cut -c1-7`

# TODO: multiple pushes
# IDEA: put outside this function ref: http://www.savvyclutch.com/devops/continuous-deployment-to-aws-ecs-and-circle-ci/
echo "pushing"
docker tag $DOCKER_SOURCE_IMAGE:${DOCKER_TAG:-latest} $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/ci-rack:$SHA1
time docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/ci-rack:$SHA1

echo "deploying"
time ./ecspresso deploy --config=$1

echo "notifying"
