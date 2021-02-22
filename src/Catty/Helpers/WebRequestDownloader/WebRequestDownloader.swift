/**
 *  Copyright (C) 2010-2020 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

public class WebRequestDownloader: NSObject {
    private var completion: ((String?, Error?) -> Void)?
    private var data = Data()
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var url = String()
    
    required init(url: String, session: URLSession?) {
        super.init()
        self.url = url
        self.session = session != nil ? session : self.defaultSession()
    }
    
    private func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func download(completion: @escaping (String?, Error?) -> Void) {
        self.completion = completion
        guard let url =  URL(string: url) else { completion(nil, WebRequestDownloadError.invalidUrl); return }
        task = session?.dataTask(with: url)
        task?.resume()
    }
}

extension WebRequestDownloader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let totalBytesExpectedToWrite = self.data.count + data.count
        if totalBytesExpectedToWrite > NetworkDefines.kWebRequestMaxDownloadSize {
            task?.cancel()
        }
        self.data.append(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let completion = self.completion {
            if error != nil {
                data.removeAll()
                if (error as NSError?)?.code == NSURLErrorCancelled {
                    completion(nil, WebRequestDownloadError.downloadSize)
                } else {
                    completion(nil, WebRequestDownloadError.unexpectedError)
                }
            } else {
                completion(String(decoding: data, as: UTF8.self), nil)
            }
        }
    }
}

enum WebRequestDownloadError: Error {
    /// Indicates an invalid URL
    case invalidUrl
    /// Indicates a download bigger than kWebRequestMaxDownloadSize
    case downloadSize
    /// Indicates an unexpected error
    case unexpectedError
}
