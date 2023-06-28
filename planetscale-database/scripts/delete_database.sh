echo "PlanetScale database branch to delete is $TARGET_BRANCH_NAME"

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

    if [ "$existing_branch_response_code" -eq 200 ]; then
        BRANCH_ID=$(echo "$existing_branch_response_body" | jq -r '.id')
        echo "Database branch $TARGET_BRANCH_NAME exists in PlanetScale, ID $BRANCH_ID."
    elif [ "$existing_branch_response_code" -eq 404 ]; then
        echo "Database branch $TARGET_BRANCH_NAME does not exist in PlanetScale, nothing to delete."
        exit 0
    else
        echo "HTTP Error: $code"
        echo "$existing_branch_response_body"
        exit 1
    fi
fi

echo "Deleting the database branch..."

# todo
delete_branch_response=$( \
    curl -s -w "\n%{http_code}" \
        --request DELETE \
        --url https://api.planetscale.com/v1/organizations/$ORGANIZATION/databases/$DATABASE/branches/$TARGET_BRANCH_NAME \
        --header "Authorization: $SERVICE_TOKEN_ID:$SERVICE_TOKEN" \

)
delete_branch_response_code=$(echo "$delete_branch_response" | tail -n1)
delete_branch_response_body=$(echo "$delete_branch_response" | sed '$d')

if [ "$delete_branch_response_code" -eq 204 ]; then
    echo "Successfully deleted database branch $TARGET_BRANCH_NAME."
else
    echo "Error deleting database branch $TARGET_BRANCH_NAME."
    echo "HTTP Error: $delete_branch_response_code"
    echo "$delete_branch_response_body"
    exit 1
fi
