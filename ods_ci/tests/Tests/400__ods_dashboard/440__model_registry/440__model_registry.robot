*** Settings ***
Documentation      Test suite for Nodel Registry
Suite Setup       Prepare Model Registry Test Setup
Suite Teardown    Teardown Model Registry Test Setup
Library           OperatingSystem
Library           Process
Library           OpenShiftLibrary
Resource          ../../../Resources/Page/ODH/JupyterHub/HighAvailability.robot


*** Variables ***
${MODEL_REGISTRY_REPO_BRANCH}       %{MODEL_REGISTRY_REPO_BRANCH=main}
${MODEL_REGISTRY_REPO_REPO_URL}     %{MODEL_REGISTRY_REPO_REPO_URL=https://github.com/opendatahub-io/model-registry-operator.git}
${MODEL_REGISTRY_DIR}               model_registry
${MODEL_REGISTRY_NAMESPACE}         model-registry-project


*** Test Cases ***
Verify Model Registry Integration With Jupyter Notebook
    [Documentation]    Verifies the Integartion of Model Registry operator with Jupyter Notebook
    [Tags]    OpenDataHub    RunThisTest    robot:recursive-continue-on-failure
     Pass Execution    The Test is executed as part of Suite Setup

*** Keywords ***
Prepare Model Registry Test Setup
    [Documentation]    Suite setup steps for testing Model Registry.
    Set Library Search Order    SeleniumLibrary
    #Skip If Component Is Not Enabled    modelregistry
    RHOSi Setup
    Apply Db Config Samples
    Launch Dashboard    ${TEST_USER.USERNAME}    ${TEST_USER.PASSWORD}    ${TEST_USER.AUTH_TYPE}
    ...    ${ODH_DASHBOARD_URL}    ${BROWSER.NAME}    ${BROWSER.OPTIONS}
    Fetch CA Certificate If RHODS Is Self-Managed

Apply Db Config Samples
    [Documentation]
     ${result} =    Run Process    git clone -b ${MODEL_REGISTRY_REPO_BRANCH} ${MODEL_REGISTRY_REPO_REPO_URL} ${MODEL_REGISTRY_DIR}
    ...    shell=true    stderr=STDOUT
    Log To Console    ${result.stdout}
    IF    ${result.rc} != 0
        FAIL    Unable to clone model-registry repo ${MODEL_REGISTRY_REPO_BRANCH} ${MODEL_REGISTRY_REPO_REPO_URL} ${MODEL_REGISTRY_DIR}
    END
    ${rc}    ${out}=    Run And Return Rc And Output    oc new-project ${MODEL_REGISTRY_NAMESPACE}
    Should Be Equal As Integers	   ${rc}	 0  msg=Cannot create a new project ${MODEL_REGISTRY_NAMESPACE}
    ${rc}    ${out}=    Run And Return Rc And Output
    ...    oc apply -k ${MODEL_REGISTRY_DIR}/config/samples/postgres


Teardown Model Registry Test Setup
    [Documentation]  Teardown Model Registry Suite
    Close All Browsers
    ${return_code} =	  Run And Return Rc  rm -rf ${MODEL_REGISTRY_DIR}
    Should Be Equal As Integers	  ${return_code}	 0



