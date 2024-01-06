import json


def handler(request, **kwargs):
    print(json.dumps(request.__dict__, default=repr))
    return "Hello World!"
