import { util } from '@aws-appsync/utils';

export function request(ctx) {
    ctx.stash.timestamp = util.time.nowEpochMilliSeconds();
    console.log('timestamp:', ctx.stash.timestamp);
    return {};
}

export function response(ctx) {
    return ctx.prev.result;
}