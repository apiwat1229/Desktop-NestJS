const nodeExternals = require('webpack-node-externals');

module.exports = function (options, webpack) {
    return {
        ...options,
        externals: [
            nodeExternals({
                allowlist: ['webpack/hot/poll?100'],
            }),
            function ({ request }, callback) {
                // Externalize @prisma/client, .prisma/client, and bcrypt
                if (request === '@prisma/client' || request === '.prisma/client' || request === 'bcrypt') {
                    return callback(null, 'commonjs ' + request);
                }
                callback();
            },
        ],
        module: {
            ...options.module,
            rules: [
                ...options.module.rules,
                {
                    test: /\.html$/,
                    type: 'asset/resource',
                },
            ],
        },
        plugins: [
            ...options.plugins,
            new webpack.IgnorePlugin({
                resourceRegExp: /^(mock-aws-s3|aws-sdk|nock)$/,
            }),
        ],
    };
};
