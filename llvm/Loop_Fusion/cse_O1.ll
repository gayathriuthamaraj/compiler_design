; ModuleID = 'example_1_1.c'
source_filename = "example_1_1.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc19.33.0"

; Function Attrs: nofree norecurse nosync nounwind memory(none) uwtable
define dso_local i32 @main() local_unnamed_addr #0 {
  %1 = alloca [5 x i32], align 16
  %2 = alloca [5 x i32], align 16
  call void @llvm.lifetime.start.p0(ptr nonnull %1) #2
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #2
  br label %3

3:                                                ; preds = %0, %3
  %4 = phi i64 [ 0, %0 ], [ %8, %3 ]
  %5 = getelementptr inbounds nuw i32, ptr %1, i64 %4
  %6 = trunc i64 %4 to i32
  %7 = shl i32 %6, 1
  store i32 %7, ptr %5, align 4
  %8 = add nuw nsw i64 %4, 1
  %9 = icmp eq i64 %8, 5
  br i1 %9, label %13, label %3, !llvm.loop !8

10:                                               ; preds = %13
  %11 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %12 = load i32, ptr %11, align 8
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #2
  call void @llvm.lifetime.end.p0(ptr nonnull %1) #2
  ret i32 %12

13:                                               ; preds = %3, %13
  %14 = phi i64 [ %19, %13 ], [ 0, %3 ]
  %15 = getelementptr inbounds nuw i32, ptr %1, i64 %14
  %16 = load i32, ptr %15, align 4
  %17 = add nsw i32 %16, 1
  %18 = getelementptr inbounds nuw i32, ptr %2, i64 %14
  store i32 %17, ptr %18, align 4
  %19 = add nuw nsw i64 %14, 1
  %20 = icmp eq i64 %19, 5
  br i1 %20, label %10, label %13, !llvm.loop !11
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

attributes #0 = { nofree norecurse nosync nounwind memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "clang version 22.1.0 (https://github.com/llvm/llvm-project 4434dabb69916856b824f68a64b029c67175e532)", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "example_1_1.c", directory: "C:\\SEM-6\\COMPILER-DESIGN\\compiler_design\\llvm\\Loop_Fusion")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"clang version 22.1.0 (https://github.com/llvm/llvm-project 4434dabb69916856b824f68a64b029c67175e532)"}
!8 = distinct !{!8, !9, !10}
!9 = !{!"llvm.loop.mustprogress"}
!10 = !{!"llvm.loop.unroll.disable"}
!11 = distinct !{!11, !9, !10}
