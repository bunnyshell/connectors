echo "Xata designated database branch is $TARGET_BRANCH_NAME"

if [ -n "$BRANCH_ID" ]; then
    echo "Checking to see if the database branch $TARGET_BRANCH_NAME ($BRANCH_ID) already exists..."

    existing_branch_response=$( \
        curl -s -w "\n%{http_code}" \
                --request GET \
                --url https://$WORKSPACE.$REGION.xata.sh/db/$DB_NAME:$TARGET_BRANCH_NAME \
                --header 'accept: application/json' \
                --header "authorization: Bearer $API_TOKEN" \
    )
    existing_branch_response_code=$(echo "$existing_branch_response" | tail -n1)
    existing_branch_response_body=$(echo "$existing_branch_response" | sed '$d')

    if [ "$existing_branch_response_code" -eq 200 ]; then
        echo "Database branch $TARGET_BRANCH_NAME exists in Xata, ID $BRANCH_ID."
    elif [ "$existing_branch_response_code" -eq 404 ]; then
        echo "Database branch $TARGET_BRANCH_NAME does not exist in Xata, nothing to delete."
        exit 0
    else
        echo "HTTP Error: $code"
        echo "$existing_branch_response_body"
        exit 1
    fi
fi

echo "Deleting the database branch..."

delete_branch_response=$( \
    curl -s -w "\n%{http_code}" \
        --request DELETE \
        --url https://$WORKSPACE.$REGION.xata.sh/db/$DB_NAME:$TARGET_BRANCH_NAME \
        --header 'accept: application/json' \
        --header "authorization: Bearer $API_TOKEN" \
)
delete_branch_response_code=$(echo "$delete_branch_response" | tail -n1)
delete_branch_response_body=$(echo "$delete_branch_response" | sed '$d')

if [ "$delete_branch_response_code" -eq 200 ]; then
    echo "Successfully deleted database branch $TARGET_BRANCH_NAME."
else
    echo "Error deleting database branch $TARGET_BRANCH_NAME."
    echo "HTTP Error: $delete_branch_response_code"
    echo "$delete_branch_response_body"
    exit 1
fi
