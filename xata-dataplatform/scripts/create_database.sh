echo "Xata designated database branch is $TARGET_BRANCH"

if [ -n "$BRANCH_ID" ]; then
    echo "Checking to see if the database branch $TARGET_BRANCH ($BRANCH_ID) already exists..."

    existing_branch_response=$( \
        curl -s -w "\n%{http_code}" \
                --request GET \
                --url https://$WORKSPACE.$REGION.xata.sh/db/$DB_NAME:$TARGET_BRANCH \
                --header 'accept: application/json' \
                --header "authorization: Bearer $API_TOKEN" \
    )
    existing_branch_response_code=$(echo "$existing_branch_response" | tail -n1)
    existing_branch_response_body=$(echo "$existing_branch_response" | sed '$d')

    if [ "$existing_branch_response_code" -eq 404 ]; then
        echo "Database branch $TARGET_BRANCH does not exist in Xata."
    elif [ "$existing_branch_response_code" -eq 200 ]; then
        echo "Database branch $TARGET_BRANCH already exists in Xata, ID $BRANCH_ID."
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
        --request PUT \
        --url https://$WORKSPACE.$REGION.xata.sh/db/$DB_NAME:$TARGET_BRANCH?from=$SOURCE_BRANCH \
        --header 'accept: application/json' \
        --header "authorization: Bearer $API_TOKEN" \
)
create_branch_response_code=$(echo "$create_branch_response" | tail -n1)
create_branch_response_body=$(echo "$create_branch_response" | sed '$d')

if [ "$create_branch_response_code" -eq 201 ]; then
    echo "Successfully created database branch $TARGET_BRANCH."

    existing_branch_response=$( \
        curl -s -w "\n%{http_code}" \
                --request GET \
                --url https://$WORKSPACE.$REGION.xata.sh/db/$DB_NAME:$TARGET_BRANCH \
                --header 'accept: application/json' \
                --header "authorization: Bearer $API_TOKEN" \
    )

    existing_branch_response_code=$(echo "$existing_branch_response" | tail -n1)
    existing_branch_response_body=$(echo "$existing_branch_response" | sed '$d')

    DB_HOST="https://$WORKSPACE.$REGION.xata.sh/db/$DB_NAME"
    BRANCH_ID=$(echo "$existing_branch_response_body" | jq -r '.id')

    echo "Host: $DB_HOST"
    echo "Branch ID: $BRANCH_ID"
else
    echo "Error creating database branch $TARGET_BRANCH."
    echo "HTTP code: $create_branch_response_code"
    echo "$create_branch_response_body"
    exit 1
fi
