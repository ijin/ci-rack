#!/bin/bash
set -x

eval $(aws --region ap-northeast-1 ecr get-login --no-include-email)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text | awk '{print $1}')
export SHA1=`echo ${CIRCLE_SHA1} | cut -c1-7`

# TODO: multiple pushes
# IDEA: put outside this function ref: http://www.savvyclutch.com/devops/continuous-deployment-to-aws-ecs-and-circle-ci/
echo "pushing"
docker tag $DOCKER_IMAGE:${DOCKER_TAG:-latest} $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/ci-rack:$SHA1
time docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/ci-rack:$SHA1

echo "deploying"
time ./ecspresso deploy --config=$1

echo "notifying"
if [ $? -eq 0 ]; then
    export SL_COLOR="good"
    export SL_TEXT="Success: Deployed ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://www.cloudbees.com/sites/default/files/eleasticbeanstalk_square.png"
    export EXIT=0
else
    export SL_COLOR="danger"
    export SL_TEXT="Failure: Deploying ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://www.cloudbees.com/sites/default/files/eleasticbeanstalk_square.png"
    export EXIT=1
fi

curl -X POST --data-urlencode 'payload={"username": "Elastic Beanstalk ('"$CIRCLE_PROJECT_REPONAME"')", "icon_url": "'"$SL_ICON"'", "channel": "'"${CHANNEL:-#test}"'", "a
ttachments": [{ "color": "'"$SL_COLOR"'", "text": "'"$SL_TEXT"'", "mrkdwn_in": ["text"] }] }' https://hooks.slack.com/services/${SLACK_HOOK}

exit $EXIT
