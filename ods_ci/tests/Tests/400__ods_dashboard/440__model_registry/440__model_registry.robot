*** Settings ***
Documentation      Test suite for Nodel Registry
Suite Setup       Prepare Model Registry Test Setup
Suite Teardown    Teardown Model Registry Test Setup
Library           OperatingSystem
Library           Process
Library           OpenShiftLibrary
Resource          ../../../Resources/Page/ODH/JupyterHub/HighAvailability.robot
Resource          ../../../Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/Projects.resource
Resource          ../../../Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/DataConnections.resource


*** Variables ***
${MODEL_REGISTRY_REPO_BRANCH}       %{MODEL_REGISTRY_REPO_BRANCH=main}
${MODEL_REGISTRY_REPO_REPO_URL}     %{MODEL_REGISTRY_REPO_REPO_URL=https://github.com/opendatahub-io/model-registry-operator.git}
${MODEL_REGISTRY_DIR}               model_registry
${PRJ_TITLE}                        model-registry-project
${PRJ_DESCRIPTION}                  model resgistry project
${aws_bucket}=                      ${S3.BUCKET_2.NAME}


*** Test Cases ***
Verify Model Registry Integration With Jupyter Notebook
    [Documentation]    Verifies the Integartion of Model Registry operator with Jupyter Notebook
    [Tags]    OpenDataHub    RunThisTest    robot:recursive-continue-on-failure
    Create Workbench    workbench_title=registry-wb    workbench_description=Registry test
    ...                 prj_title=${PRJ_TITLE}    image_name=Minimal Python  deployment_size=Small
    ...                 data_connection=model-serving-connection   storage=Persistent   pv_existent=${NONE}
    ...                 pv_name=${NONE}  pv_description=${NONE}  pv_size=${NONE}
    Create S3 Data Connection    project_title=${PRJ_TITLE}    dc_name=model-serving-connection
    ...            aws_access_key=${S3.AWS_ACCESS_KEY_ID}    aws_secret_access=${S3.AWS_SECRET_ACCESS_KEY}
    ...            aws_bucket_name=${aws_bucket}
    Run Keyword And Continue On Failure
    ...    Wait Until Workbench Is Started     workbench_title=registry-wb


*** Keywords ***
Prepare Model Registry Test Setup
    [Documentation]    Suite setup steps for testing Model Registry.
    Set Library Search Order    SeleniumLibrary
    #Skip If Component Is Not Enabled    modelregistry
    RHOSi Setup
    Launch Dashboard    ${TEST_USER.USERNAME}    ${TEST_USER.PASSWORD}    ${TEST_USER.AUTH_TYPE}
    ...    ${ODH_DASHBOARD_URL}    ${BROWSER.NAME}    ${BROWSER.OPTIONS}
    Open Data Science Projects Home Page
    Create Data Science Project    title=${PRJ_TITLE}    description=${PRJ_DESCRIPTION}
    Apply Db Config Samples    namespace=${PRJ_TITLE}
    Fetch CA Certificate If RHODS Is Self-Managed

Apply Db Config Samples
    [Documentation]    Applying the db config samples from https://github.com/opendatahub-io/model-registry-operator
    [Arguments]    ${namespace}
    ${result} =    Run Process    git clone -b ${MODEL_REGISTRY_REPO_BRANCH} ${MODEL_REGISTRY_REPO_REPO_URL} ${MODEL_REGISTRY_DIR}
    ...    shell=true    stderr=STDOUT
    Log To Console    ${result.stdout}
    IF    ${result.rc} != 0
        FAIL    Unable to clone model-registry repo ${MODEL_REGISTRY_REPO_BRANCH} ${MODEL_REGISTRY_REPO_REPO_URL} ${MODEL_REGISTRY_DIR}
    END
    ${rc}    ${out}=    Run And Return Rc And Output
    ...    oc apply -k ${MODEL_REGISTRY_DIR}/config/samples/postgres -n ${namespace}

Teardown Model Registry Test Setup
    [Documentation]  Teardown Model Registry Suite
    #JupyterLibrary.Close All Browsers
    #${return_code} =	  Run And Return Rc  rm -rf ${MODEL_REGISTRY_DIR}
    #Should Be Equal As Integers	  ${return_code}	 0
    #Delete Data Science Project   project_title=${PRJ_TITLE}

