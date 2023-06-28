echo "PlanetScale designated database branch is $TARGET_BRANCH_NAME"

if [ -n "$TARGET_BRANCH_NAME" ]; then
    echo "Checking to see if the database branch $TARGET_BRANCH_NAME exists..."

    existing_branch_response=$( \
        curl -s -w "\n%{http_code}" \
                --request GET \
                --url https://api.planetscale.com/v1/organizations/$ORGANIZATION/databases/$DATABASE/branches/$TARGET_BRANCH_NAME \
                --header "Authorization: $SERVICE_TOKEN_ID:$SERVICE_TOKEN" \
                --header 'accept: application/json' \
    )
    existing_branch_response_code=$(echo "$existing_branch_response" | tail -n1)
    existing_branch_response_body=$(echo "$existing_branch_response" | sed '$d')

    if [ "$existing_branch_response_code" -eq 404 ]; then
        echo "Database branch $TARGET_BRANCH_NAME does not exist in PlanetScale."
    elif [ "$existing_branch_response_code" -eq 200 ]; then
        BRANCH_ID=$(echo "$existing_branch_response_body" | jq -r '.id')
        echo "Database branch $TARGET_BRANCH_NAME already exists in PlanetScale, ID $BRANCH_ID."
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
        --url https://api.planetscale.com/v1/organizations/$ORGANIZATION/databases/$DATABASE/branches \
        --header "Authorization: $SERVICE_TOKEN_ID:$SERVICE_TOKEN" \
        --header 'accept: application/json' \
        --header 'content-type: application/json' \
        --data "{\"name\": \"$TARGET_BRANCH_NAME\", \"parent_branch\": \"$SOURCE_BRANCH_NAME\"}" \
)
create_branch_response_code=$(echo "$create_branch_response" | tail -n1)
create_branch_response_body=$(echo "$create_branch_response" | sed '$d')

if [ "$create_branch_response_code" -eq 201 ]; then
    echo "Successfully created database branch $TARGET_BRANCH_NAME."
else
    echo "Error creating database branch $TARGET_BRANCH_NAME."
    echo "HTTP code: $create_branch_response_code"
    echo "$create_branch_response_body"
    exit 1
fi

echo "Creating the password for database branch..."

create_password_response=$( \
    curl -s -w "\n%{http_code}" \
         --request POST \
         --url https://api.planetscale.com/v1/organizations/$ORGANIZATION/databases/$DATABASE/branches/$TARGET_BRANCH_NAME/passwords \
         --header "Authorization: $SERVICE_TOKEN_ID:$SERVICE_TOKEN" \
         --header 'accept: application/json' \
         --header 'content-type: application/json' \
         --data "{\"name\": \"bunnyshell-$TARGET_BRANCH_NAME\", \"role\": \"admin\"}" \
)
create_password_response_code=$(echo "$create_password_response" | tail -n1)
create_password_response_body=$(echo "$create_password_response" | sed '$d' | tr -d '\000-\037')

if [ "$create_password_response_code" -eq 201 ]; then
    echo "Successfully created password for database branch $TARGET_BRANCH_NAME."
    DB_HOST=$(echo "$create_password_response_body" | jq -r '.access_host_url')
    DB_USERNAME=$(echo "$create_password_response_body" | jq -r '.username')
    DB_PASSWORD=$(echo "$create_password_response_body" | jq -r '.plain_text')
    echo "Host: $DB_HOST"
    echo "Username: $DB_USERNAME"
    echo "Password: ******************************"
else
    echo "Error creating password for database branch $TARGET_BRANCH_NAME."
    echo "HTTP code: $create_password_response_code"
    echo "$create_password_response_body"
    exit 1
fi
