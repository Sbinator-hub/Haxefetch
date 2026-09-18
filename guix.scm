(use-modules ((guix licenses) #:prefix license:)
             (gnu packages compression)
             (gnu packages haxe)
             (gnu packages haxe)
             (guix build-system gnu)
             (guix download)
             (guix gexp)
             (guix git-download)
             (guix packages)
             (guix utils))

(define-public haxefetch
  (let ((3rd/haxelib
         (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/HaxeFoundation/haxelib")
                (commit "4.2.0")
                (recursive? #t)))
          (file-name "haxelib-4.2.0-checkout")
          (sha256
           (base32
            "0bgd6yk4rdscaiyxxgq2l1i4zbb1npimibr5l51l4dbhg1d4wbq6"))))
        (3rd/hxcpp
         (origin
          (method url-fetch)
          (uri "https://lib.haxe.org/p/hxcpp/4.3.2/download/")
          (file-name "hxcpp-4.3.2.zip")
          (sha256
           (base32
            "1qlz99s6zh1780b0vxh1sa3l4aiz1r0pmxdhqqi7k8rggfpyfcl9")))))
    (package
     (name "haxefetch")
     (version "1.0.0")
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Sbinator-hub/Haxefetch")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "04fhgklw135r4cra4yl1aj0l6ca8l2hpgp3d45kd8jgip1paxy69"))
       (modules '((guix build utils)))
       (snippet
        #~(begin
            (copy-recursively #$3rd/haxelib "3rd/haxelib")
            (copy-recursively #$3rd/hxcpp "3rd/hxcpp.zip")))))
     (build-system gnu-build-system)
     (arguments
      (list #:tests? #f
            #:phases
            #~(modify-phases %standard-phases
                             (add-after 'unpack 'unpack-hxcpp
                               (lambda _
                                 (invoke "unzip" "3rd/hxcpp.zip" "-d" "3rd")))
                             (add-before 'configure 'setup-haxelib-and-hxcpp
                               (lambda _
                                 (setenv "HOME" (getcwd))
                                 (invoke "haxelib" "setup" "3rd/haxelib")
                                 (invoke "haxelib" "dev" "hxcpp"
                                         (string-append (getcwd)
                                                        "/3rd/hxcpp-4.3.2"))))
                             (delete 'configure)
                             (replace 'build
                               (lambda _
                                 (let ((haxe-arch
                                        (cond
                                         (#$(target-x86-64?) "HXCPP_M64")
                                         (#$(target-x86-32?) "HXCPP_M32")
                                         (#$(target-arm32?) "HXCPP_ARMV7")
                                         (#$(target-arm?) "HXCPP_ARM64")
                                         (else (error "unsupported target")))))
                                   (invoke "haxe" "build.hxml"
                                           "-D" haxe-arch
                                           "-D" "no_debug"))))
                             (replace 'install
                               (lambda _
                                 (install-file "bin/cpp/haxefetch"
                                               (string-append #$output
                                                              "/bin")))))))
     (native-inputs (list haxe unzip neko))
     (home-page "https://github.com/Sbinator-hub/Haxefetch")
     (synopsis "A fetch program written in Haxe")
     (description
      "Haxefetch is fetch program inspired by fastfetch, neofetch, pfetch,
nerdfetch, hyfetch, and so on, written in Haxe.")
     (license (list license:bsd-2 ;; hxcpp
                    license:expat)))))

haxefetch
