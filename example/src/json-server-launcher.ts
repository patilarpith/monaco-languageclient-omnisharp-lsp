/* --------------------------------------------------------------------------------------------
 * Copyright (c) 2018 TypeFox GmbH (http://www.typefox.io). All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for license information.
 * ------------------------------------------------------------------------------------------ */
import * as fs from 'fs';
import * as rpc from "vscode-ws-jsonrpc";
import * as server from "vscode-ws-jsonrpc/lib/server";
import {
  InitializeRequest, InitializeParams,
  DidOpenTextDocumentNotification, DidOpenTextDocumentParams
} from 'vscode-languageserver';

export function launch(socket: rpc.IWebSocket) {
    const reader = new rpc.WebSocketMessageReader(socket);
    const writer = new rpc.WebSocketMessageWriter(socket);

    // start the language server as an external process
    const socketConnection = server.createConnection(reader, writer, () => socket.dispose());
    const serverConnection = server.createServerProcess('LSP', '/opt/omnisharp/run', ['-lsp', '-debug']);
    server.forward(socketConnection, serverConnection, message => {
        if (rpc.isRequestMessage(message)) {
            if (message.method === InitializeRequest.type.method) {
                const initializeParams = message.params as InitializeParams;
                initializeParams.processId = process.pid;
            }
        }
        if (rpc.isNotificationMessage(message)) {
            switch (message.method) {
                case DidOpenTextDocumentNotification.type.method: {
                    const didOpenParams = message.params as DidOpenTextDocumentParams;
                    const uri = didOpenParams.textDocument.uri;
                    const text = didOpenParams.textDocument.text;
                    if (uri) fs.writeFileSync(uri.replace('file://', ''), text)
                    break;
                }
            }
        }
        return message;
    });

}
