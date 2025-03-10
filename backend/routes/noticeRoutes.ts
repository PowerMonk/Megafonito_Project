import { router, validation } from "./routesMod.ts";
import {
  createNoticeHandler,
  getNoticesByUserHandler,
  noticeUpdaterHandler,
  noticeDeleterHandler,
  getNoticeByUserAndIdHandler,
  getNoticesByNoticeIdHandler,
  getAllNoticesHandler,
  getPaginatedNoticesHandler,
  // uploadFileHandler,
  // serveFileHandler,
} from "../controllers/controllersMod.ts";
import { authMiddleware } from "../auth/authMod.ts";
import {
  s3UploadHandler,
  s3FetchHandler,
  s3ListHandler,
  s3DeleteHandler,
} from "../proxy/proxyMod.ts";

router
  .post("/notices", validation.validateNoticeCreation, createNoticeHandler)
  .get("/allnotices", authMiddleware, getAllNoticesHandler)
  .get("/notices", getPaginatedNoticesHandler)
  .get("/notices/:userId", authMiddleware, getNoticesByUserHandler)
  .get(
    "/notices/anuncio/:noticeId",
    authMiddleware,
    getNoticesByNoticeIdHandler
  )
  .get(
    "/notices/:userId/:noticeId",
    authMiddleware,
    getNoticeByUserAndIdHandler
  )
  .put("/notices/:noticeId", authMiddleware, noticeUpdaterHandler)
  .delete("/notices/:noticeId", authMiddleware, noticeDeleterHandler)
  // .post("/upload", authMiddleware, uploadFileHandler)
  // .get("/files/:fileName", serveFileHandler)
  // S3 file routes
  .post("/upload/s3", authMiddleware, s3UploadHandler)
  .get("/s3/files/:fileKey", s3FetchHandler)
  .get("/s3/list", authMiddleware, s3ListHandler)
  .delete("/s3/files/:fileKey", authMiddleware, s3DeleteHandler);
