#!/usr/bin/env ash
set -x

# Copy all environment variables which start with INPUT_, GITHUB_, RUNNER_ or ACTIONS_
# Also set HOME and CI

vars=$(env | egrep '^INPUT_|^GITHUB_|^RUNNER_|^ACTIONS_' | sed -e 's+=.*$++')
vars=$(echo $vars | sed -e 's+ + -e +g')
vars=${vars:+"-e $vars"}
if [ -n "${HOME}" ] ; then
  vars="${vars} -e HOME"
fi
if [ -n "${CI}" ] ; then
  vars="${vars} -e CI"
fi

mounts="-v /var/run/docker.sock:/var/run/docker.sock"
if [ -n "${RUNNER_TEMP}" ] ; then
  mounts="${mounts} -v ${RUNNER_TEMP}/_github_home:/github/home"
  mounts="${mounts} -v ${RUNNER_TEMP}/_github_workflow:/github/workflow"
  mounts="${mounts} -v ${RUNNER_TEMP}/_runner_file_commands:/github/file_commands"
fi

if [ -n "${RUNNER_WORKSPACE}" -a -n "${GITHUB_REPOSITORY}" ] ; then
  mounts="${mounts} -v ${RUNNER_WORKSPACE}/${GITHUB_REPOSITORY//*\//}:${GITHUB_WORKSPACE}"
fi

if [ -n "${RUNNER_TOOL_CACHE}" ] ; then
  mounts="${mounts} -v ${RUNNER_TOOL_CACHE}:${RUNNER_TOOL_CACHE}"
fi

echo exec docker run --workdir "${GITHUB_WORKSPACE}" --rm ${vars} ${mounts} "${INPUT_DOCKER_IMAGE}"
exec docker run --workdir "${GITHUB_WORKSPACE}" --rm ${vars} ${mounts} "${INPUT_DOCKER_IMAGE}"
