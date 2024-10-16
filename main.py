from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
import config as c

app = FastAPI()
templates = Jinja2Templates(directory="templates") # templatesフォルダがプロジェクトのルートにあると仮定

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse("index.html", {
            "request": request, 
            "CONFIG_ID": c.CONFIG_ID,
            "JWT_OR_OAUTH": c.JWT_OR_OAUTH,
        })


# 別のページの例
@app.get("/about", response_class=HTMLResponse)
async def about(request: Request):
    return templates.TemplateResponse("about.html", {"request": request, "message": "This is the about page."})

if __name__ == "__main__":
    import uvicorn
    import os
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8080")))
