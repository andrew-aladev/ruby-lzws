ARG FROM_IMAGE
FROM $FROM_IMAGE

COPY root /
RUN cp -R /mnt/common-root/* /
RUN build.sh -v \
  dev-vcs/git dev-util/cmake \
  dev-libs/gmp dev-libs/libtommath app-arch/ncompress \
  dev-lang/ruby:2.5 dev-lang/ruby:2.6 dev-lang/ruby:2.7 dev-lang/ruby:3.0 \
  virtual/rubygems && \
  cleanup.sh
