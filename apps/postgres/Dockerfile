FROM docker.io/postgres:18.1-alpine AS builder

RUN apk add curl clang18 clang18-dev postgresql postgresql-dev make
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain beta

ENV CC=clang-18
ENV RUSTC_BOOTSTRAP=1
ENV PATH=/root/.cargo/bin:${PATH}

WORKDIR /src
RUN curl -fsSL https://github.com/tensorchord/VectorChord/archive/refs/tags/1.1.1.tar.gz | tar -xz --strip-components=1
COPY config.toml .cargo/config.toml

RUN make build



FROM docker.io/postgres:18.1-alpine

RUN pg_config --sharedir && pg_config --pkglibdir
RUN apk add postgresql-pgvector

RUN mv /usr/lib/postgresql18/vector.so /usr/local/lib/postgresql
RUN mv /usr/share/postgresql18/extension/vector* /usr/local/share/postgresql/extension/

COPY --from=builder /src/build/pkglibdir/* /usr/local/lib/postgresql
COPY --from=builder /src/build/sharedir/* /usr/local/share/postgresql/extension/

COPY create-extension.sql /docker-entrypoint-initdb.d/

# RUN wget "https://github.com/tensorchord/VectorChord/releases/download/1.1.1/postgresql-18-vchord_1.1.1_x86_64-linux-gnu.zip" -O /tmp/vchord.zip \
#   && cd /tmp \
#   && unzip /tmp/vchord.zip \
#   && cp -r /tmp/pkglibdir/. $(pg_config --pkglibdir) \
#   && cp -r /tmp/sharedir/. $(pg_config --sharedir) \
#   && rm -rf /tmp/*

CMD [ "postgres", "-c", "shared_preload_libraries=vchord,vector" ]
