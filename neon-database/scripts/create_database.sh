echo "Neon designated database branch is $TARGET_BRANCH_NAME"

if [ -n "$BRANCH_ID" ]; then
    echo "Checking to see if the database branch $TARGET_BRANCH_NAME ($BRANCH_ID) already exists..."

    existing_branch_response=$( \
        curl -s -w "\n%{http_code}" \
                --request GET \
                --url https://console.neon.tech/api/v2/projects/$PROJECT_ID/branches/$BRANCH_ID \
                --header 'accept: application/json' \
                --header "authorization: Bearer $API_TOKEN" \
    )
    existing_branch_response_code=$(echo "$existing_branch_response" | tail -n1)
    existing_branch_response_body=$(echo "$existing_branch_response" | sed '$d')

    if [ "$existing_branch_response_code" -eq 404 ]; then
        echo "Database branch $TARGET_BRANCH_NAME does not exist in Neon."
    elif [ "$existing_branch_response_code" -eq 200 ]; then
        echo "Database branch $TARGET_BRANCH_NAME already exists in Neon, ID $BRANCH_ID."
        exit 0
    else
        echo "HTTP Error: $code"
        echo "$existing_branch_response_body"
        exit 1
    fi
fi

echo "Creating the database branch..."

create_branch_response=$( \
    curl -s -w "\n%{http_code}" \
        --request POST \
        --url https://console.neon.tech/api/v2/projects/$PROJECT_ID/branches \
        --header 'accept: application/json' \
        --header "authorization: Bearer $API_TOKEN" \
        --header 'content-type: application/json' \
        --data "{\"endpoints\": [{\"type\": \"read_write\"}], \"branch\": {\"parent_id\": \"$SOURCE_BRANCH_ID\", \"name\": \"$TARGET_BRANCH_NAME\"}}" \
)
create_branch_response_code=$(echo "$create_branch_response" | tail -n1)
create_branch_response_body=$(echo "$create_branch_response" | sed '$d')

if [ "$create_branch_response_code" -eq 201 ]; then
    echo "Successfully created database branch $TARGET_BRANCH_NAME."
    DB_HOST=$(echo "$create_branch_response_body" | jq -r '.endpoints[0].host')
    BRANCH_ID=$(echo "$create_branch_response_body" | jq -r '.branch.id')
    echo "Host: $DB_HOST"
    echo "Branch ID: $BRANCH_ID"
else
    echo "Error creating database branch $TARGET_BRANCH_NAME."
    echo "HTTP code: $create_branch_response_code"
    echo "$create_branch_response_body"
    exit 1
fi
