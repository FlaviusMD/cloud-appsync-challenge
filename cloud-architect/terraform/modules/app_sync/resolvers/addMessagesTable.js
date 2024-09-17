import { util } from '@aws-appsync/utils';

export function request(ctx) {
    console.log('addMessagesTable.js request function');
    console.log('ctx.args:', ctx.args);
    console.log('ctx.stash:', ctx.stash);

    return {
        operation: "PutItem",
        key: {
            userUuid: util.dynamodb.toDynamoDB(ctx.args.userUuid),
            messageTimestamp: util.dynamodb.toDynamoDB(ctx.stash.timestamp)
        },
        attributeValues: {
            messageText: util.dynamodb.toDynamoDB(ctx.args.messageText)
        }
    };
}

export function response(ctx) {
    if (ctx.error) {
        console.log('addMessagesTable - error:', JSON.stringify(ctx.error));
        util.error(ctx.error.message, ctx.error.type);
    }
    return {
        userUuid: ctx.args.userUuid,
        messageTimestamp: ctx.stash.timestamp,
        messageText: ctx.args.messageText
    };
}