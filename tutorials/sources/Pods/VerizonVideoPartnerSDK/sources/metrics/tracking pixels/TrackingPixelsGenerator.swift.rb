#coding:ASCII-8BIT
_erbout = ''; _erbout.concat "//  Copyright 2018, Oath Inc.\n//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.\nimport Foundation "

; 

require 'YAML'
require 'FileUtils'

file = nil
Dir.chdir('..') do 
  path = "mobile-sdk-evolution/definitions/tracking pixels/tracking-pixels.yaml"
  file = File.read(path)
end

api = YAML.load(file).map { |request_name, fields|
  fields[:request_name] = request_name
  fields["parameters"] = fields["parameters"].map { |key, value|
    {
      name: key,
      nullable: value[0],
      description: value[1]
    }
  }
  fields
}

def escapeDotsIn(parameterName)
  parameterName.gsub('.','_')
end

def parameterList(parameters)
  parameters.map { |p|
    "#{escapeDotsIn(p[:name])}: String#{p[:nullable] ? "? = nil" : "" }"
  }.join(",\n\t\t")
end

_erbout.concat "\n"
; _erbout.concat "\n"
; _erbout.concat "extension TrackingPixels {\n    struct Generator {\n        private init() {}\n    }\n}\n\n"





; _erbout.concat "extension TrackingPixels.Generator {\n    "
;  for call in api ; _erbout.concat "\n"
; _erbout.concat "    static func "; _erbout.concat((call[:request_name]).to_s); _erbout.concat "(\n        "
; _erbout.concat(( parameterList(call["parameters"]) ).to_s); _erbout.concat ") -> URLComponents\n    {\n        var queryItems = [URLQueryItem]()\n        \n        "



;  for p in call["parameters"];  name = escapeDotsIn(p[:name]); if !p[:nullable]; _erbout.concat "queryItems.append(URLQueryItem(name: \""; _erbout.concat((p[:name]).to_s); _erbout.concat "\", value: "; _erbout.concat((name).to_s); _erbout.concat "))\n        "
; else; _erbout.concat "if let "; _erbout.concat((name).to_s); _erbout.concat " = "; _erbout.concat((name).to_s); _erbout.concat " { queryItems.append(URLQueryItem(name: \""; _erbout.concat((p[:name]).to_s); _erbout.concat "\", value: "; _erbout.concat((name).to_s); _erbout.concat ")) }\n        "
; end; end; _erbout.concat "\n"
; _erbout.concat "        var components = URLComponents()\n        components.path = \""
; _erbout.concat((call["anchor"]).to_s); _erbout.concat "\"\n        components.queryItems = queryItems\n        \n        return components\n    }\n    "




;  end; _erbout.concat "\n"
; _erbout.concat "}\n"
; _erbout.force_encoding(__ENCODING__)
