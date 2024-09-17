import { util } from '@aws-appsync/utils';

export function request(ctx) {
    console.log('updateUsersTable.js request function');
    console.log('ctx.args:', ctx.args);
    console.log('ctx.stash:', ctx.stash);

    return {
        operation: "UpdateItem",
        key: {
            userUuid: util.dynamodb.toDynamoDB(ctx.args.userUuid)
        },
        update: {
            expression: "SET lastMessageTimestamp = :timestamp",
            expressionValues: {
                ":timestamp": util.dynamodb.toDynamoDB(ctx.stash.timestamp)
            }
        }
    };
}

export function response(ctx) {
    if (ctx.error) {
        console.log('error:', JSON.stringify(ctx.error));
        util.error(ctx.error.message, ctx.error.type);
    }
    return ctx.prev.result;
}